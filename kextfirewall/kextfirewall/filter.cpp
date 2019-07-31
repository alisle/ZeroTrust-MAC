//
//  filter.cpp
//  kextfirewall
//
//  Created by Alex Lisle on 6/10/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#include "filter.hpp"

#include <libkern/OSMalloc.h>
#include <sys/kpi_mbuf.h>

bool filters_registered = false;

extern IOSharedDataQueue* sharedDataQueue;
extern OSMallocTag mallocTag;

// DNS Header from https://gist.github.com/fffaraz/9d9170b57791c28ccda9255b48315168
struct DNS_HEADER
{
    unsigned short id; // identification number
    
    unsigned char rd :1; // recursion desired
    unsigned char tc :1; // truncated message
    unsigned char aa :1; // authoritive answer
    unsigned char opcode :4; // purpose of message
    unsigned char qr :1; // query/response flag
    
    unsigned char rcode :4; // response code
    unsigned char cd :1; // checking disabled
    unsigned char ad :1; // authenticated data
    unsigned char z :1; // its z! reserved
    unsigned char ra :1; // recursion available
    
    unsigned short q_count; // number of question entries
    unsigned short ans_count; // number of answer entries
    unsigned short auth_count; // number of authority entries
    unsigned short add_count; // number of resource entries
};

//
// None of this would of been possible without the excellent LuLu opensource firewall.
//

kern_return_t register_filters() {
    os_log(OS_LOG_DEFAULT, "IOFirewall: registering socket filters");
    if(filters_registered) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: filters were already registered, skipping");
        return KERN_SUCCESS;
    }
    
    
    kern_return_t result = sflt_register(&tcpFilterIPV4, AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if(KERN_SUCCESS != result) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: unable to reigster tcp filter!");
        filters_registered = false;
        return result;
    } else {
        filters_registered = true;
    }
    
    result = sflt_register(&udpFilterIPV4, AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if(KERN_SUCCESS != result) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: unable to register udp filter");
        filters_registered = false;
        return result;
    } else {
        filters_registered = true;
    }
    
    return result;
}

kern_return_t unregister_filters() {
    os_log(OS_LOG_DEFAULT, "IOFirewall: unregistering socket filters");
    
    if(filters_registered) {
        kern_return_t status = sflt_unregister(TCPIPV4_HANDLE);
        if(KERN_SUCCESS != status) {
            os_log(OS_LOG_DEFAULT, "IOFirewall: unable to unregister tcp filter!");
        }
        
        status = sflt_unregister(UDPIPV4_HANDLE);
        if(KERN_SUCCESS != status) {
            os_log(OS_LOG_DEFAULT, "IOFirewall: unable to unregister udp filter!");
        }
        
        filters_registered = false;
        return status;
        
    } else {
        os_log(OS_LOG_DEFAULT, "IOFirewall: filters weren't enabled.");
        return KERN_SUCCESS;
    }
    
}

/// Callback functions.
static kern_return_t attach_socket(void **cookie, socket_t so) {
    *cookie = NULL;
    cookie_header* header = (cookie_header*)OSMalloc(sizeof(cookie_header), mallocTag);
    uuid_t* uuid = (uuid_t*)OSMalloc(sizeof(uuid_t), mallocTag);
    uuid_generate_random(*uuid);
    
    header->tag = uuid;
    *cookie = header;
    return KERN_SUCCESS;
}

static void detach_socket(void *cookie, socket_t so) {
    if( NULL != cookie) {
        cookie_header* header = (cookie_header*)cookie;
        OSFree(header->tag, sizeof(uuid_t), mallocTag);
        OSFree(cookie, sizeof(cookie_header), mallocTag);
    }
    
    return;
}

static errno_t connection_out(void *cookie, socket_t so, const struct sockaddr *to) {
    send_outbound_event((cookie_header*)cookie, so, to);
    return KERN_SUCCESS;
}

static errno_t udp_data_in(void *cookie, socket_t so, const struct sockaddr *from, mbuf_t* data, mbuf_t* control, sflt_data_flag_t flags) {
    in_port_t port = 0;
    struct sockaddr_in remote = {0};
    bzero(&remote, sizeof(remote));
    mbuf_t buffer = NULL;
    struct DNS_HEADER* dns_header;
    
    if(NULL == from) {
        // For some reason we don't have a to address yet.
        if( KERN_SUCCESS != sock_getpeername(so, (struct sockaddr *)&remote, sizeof(remote))) {
            return false;
        }
        
        from = (const struct sockaddr*)&remote;
    }
    
    port = ntohs(((const struct sockaddr_in*)from)->sin_port);
    if(53 != port) {
        return KERN_SUCCESS;
    }
    buffer = *data;
    if(NULL == buffer) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: buffer is null.");
        return KERN_SUCCESS;
    }
    
    while(MBUF_TYPE_DATA != mbuf_type(buffer)) {
        buffer = mbuf_next(buffer);
        if( NULL == buffer) {
            os_log(OS_LOG_DEFAULT, "IOFirewall: cycle through dns is still null.");
            return KERN_SUCCESS;
        }
    }
    
    if(mbuf_len(buffer) <= sizeof(struct DNS_HEADER)) {
        return KERN_SUCCESS;
    }
    
    dns_header = (struct DNS_HEADER*)mbuf_data(buffer);

    if(0 != ntohs(dns_header->rcode)) {
        return KERN_SUCCESS;
    }
    
    if(0 == ntohs(dns_header->ans_count)) {
        return KERN_SUCCESS;
    }
    
    firewall_event event = {0};
    bzero(&event, sizeof(firewall_event));
    
    event.type = dns_update;
    size_t size = sizeof(event.data.dns_event.dns_message);
    if(mbuf_len(buffer) < size) {
        size = mbuf_len(buffer);
    }

    memcpy(&event.data.dns_event.dns_message, mbuf_data(buffer), size);
    
    if(!sharedDataQueue->enqueue(&event, sizeof(event))) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: unable to post dns update into event queue");
    } else {
        os_log(OS_LOG_DEFAULT, "IOFirewall: posted DNS event");
    }
    
    

    return KERN_SUCCESS;
}

static errno_t udp_data_out(void *cookie, socket_t so, const struct sockaddr *to, mbuf_t* data, mbuf_t* control, sflt_data_flag_t flags) {
    
    return KERN_SUCCESS;
}

static void unregistered(sflt_handle handle) {
    return;
}

static void filter_event(void *cookie, socket_t so, sflt_event_t event, void* param) {
    send_update_event((cookie_header*)cookie, event);
    return;
}

bool send_update_event(cookie_header* header, sflt_event_t change) {
    firewall_event event = {0};
    bzero(&event, sizeof(firewall_event));
    
    uuid_copy(event.tag, *header->tag);
    
    event.type = connection_update;
    event.data.update_event = (firewall_event_update_type)change;

    if(!sharedDataQueue->enqueue(&event, sizeof(event))) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: unable to post event into the queue");
    } else {
        os_log(OS_LOG_DEFAULT, "IOFirewall: posted update event");
    }
    
    return true;
}

bool send_outbound_event(cookie_header* header, socket_t so, const struct sockaddr *to) {
    
    firewall_event event = {0};
    
    struct sockaddr_in local = {0};
    struct sockaddr_in remote = {0};
    
    bzero(&local, sizeof(local));
    bzero(&remote, sizeof(remote));
    bzero(&event, sizeof(firewall_event));
    
    if(KERN_SUCCESS != sock_getsockname(so, (struct sockaddr *)&local, sizeof(local))) {
        return false;
    }
    
    if(NULL == to) {
        // For some reason we don't have a to address yet.
        if( KERN_SUCCESS != sock_getpeername(so, (struct sockaddr *)&remote, sizeof(remote))) {
            return false;
        }
    } else {
        memcpy(&remote, to, sizeof(remote));
    }
    
    
    
    uuid_copy(event.tag, *header->tag);
    event.type = outbound_connection;
    event.data.outbound.pid = proc_selfpid();
    event.data.outbound.ppid = proc_selfppid();
    event.data.outbound.local = local;
    event.data.outbound.remote = remote;
    
    if(!sharedDataQueue->enqueue(&event, sizeof(event))) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: unable to post event into the queue");
    } else {
        os_log(OS_LOG_DEFAULT, "IOFirewall: posted outbound event");
    }
    

    return true;
}
