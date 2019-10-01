//
//  filter.cpp
//  kextfirewall
//
//  Created by Alex Lisle on 6/10/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#include "filter.hpp"

#include <kern/clock.h>
#include <sys/time.h>
#include <libkern/OSMalloc.h>
#include <sys/kpi_mbuf.h>
#include <sys/proc.h>
#include <sys/sysctl.h>
#include <libkern/sysctl.h>
#include <IOKit/IOReturn.h>


bool in_isolation = false;
bool in_quarantine = false;
bool filters_registered = false;




static uint32_t query_offset = 0;

extern IOSharedDataQueue* sharedDataQueue;
extern OSMallocTag mallocTag;
extern IOLock* state_query_lock;

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



kern_return_t start_isolation() {
    in_isolation = true;
    
    return kIOReturnSuccess;
}

kern_return_t stop_isolation() {
    in_isolation = false;
    
    return kIOReturnSuccess;
}



kern_return_t start_quarantine() {
    in_quarantine = true;
    
    return kIOReturnSuccess;
}

kern_return_t stop_quaratine() {
    in_quarantine = false;
    
    return kIOReturnSuccess;
}

kern_return_t register_filters() {
    os_log(OS_LOG_DEFAULT, "IOFirewall: registering socket filters");
    if(filters_registered) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: filters were already registered, skipping");
        return kIOReturnSuccess;
    }
    
    
    kern_return_t result = sflt_register(&tcpFilterIPV4, AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if(kIOReturnSuccess != result) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: unable to reigster tcp filter!");
        filters_registered = false;
        return result;
    } else {
        filters_registered = true;
    }
    
    result = sflt_register(&udpFilterIPV4, AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if(kIOReturnSuccess != result) {
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
        if(kIOReturnSuccess != status) {
            os_log(OS_LOG_DEFAULT, "IOFirewall: unable to unregister tcp filter!");
        }
        
        status = sflt_unregister(UDPIPV4_HANDLE);
        if(kIOReturnSuccess != status) {
            os_log(OS_LOG_DEFAULT, "IOFirewall: unable to unregister udp filter!");
        }
        
        filters_registered = false;
        return status;
        
    } else {
        os_log(OS_LOG_DEFAULT, "IOFirewall: filters weren't enabled.");
        return kIOReturnSuccess;
    }
    
}

/// Callback functions.
static kern_return_t attach_socket(void **cookie, socket_t so) {
    *cookie = NULL;
    cookie_header* header = (cookie_header*)OSMalloc(sizeof(cookie_header), mallocTag);
    uuid_t* uuid = (uuid_t*)OSMalloc(sizeof(uuid_t), mallocTag);
    uuid_generate_random(*uuid);
    
    header->tag = uuid;
    header->outcome = UNKNOWN;
    
    *cookie = header;
    return kIOReturnSuccess;
}

static void detach_socket(void *cookie, socket_t so) {
    if( NULL != cookie) {
        cookie_header* header = (cookie_header*)cookie;
        OSFree(header->tag, sizeof(uuid_t), mallocTag);
        OSFree(cookie, sizeof(cookie_header), mallocTag);
    }
    
    return;
}

static errno_t connection_in(void *cookie, socket_t so, const struct sockaddr *from) {
    firewall_outcome_type outcome = determineDecision((cookie_header*)cookie, so, from, inbound_tcp_v4);
    
    send_tcpconnection_event((cookie_header*)cookie, so, from, outcome, inbound_connection);

    if (outcome != ALLOWED) {
        return kIOReturnError;
    }
    
    return kIOReturnSuccess;
}

static errno_t connection_out(void *cookie, socket_t so, const struct sockaddr *to) {
    firewall_outcome_type outcome = determineDecision((cookie_header*)cookie, so, to, outbound_tcp_v4);
    
    send_tcpconnection_event((cookie_header*)cookie, so, to, outcome, outbound_connection);
    
    if (outcome != ALLOWED) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: rejecting connection");
        return kIOReturnError;
    }
    
    return kIOReturnSuccess;
}

static errno_t udp_data_in(void *cookie, socket_t so, const struct sockaddr *from, mbuf_t* data, mbuf_t* control, sflt_data_flag_t flags) {
    in_port_t port = 0;
    struct sockaddr_in remote = {0};
    bzero(&remote, sizeof(remote));
    mbuf_t buffer = NULL;
    struct DNS_HEADER* dns_header;
    
    if(NULL == from) {
        // For some reason we don't have a to address yet.
        if( kIOReturnSuccess != sock_getpeername(so, (struct sockaddr *)&remote, sizeof(remote))) {
            return false;
        }
        
        from = (const struct sockaddr*)&remote;
    }
    
    port = ntohs(((const struct sockaddr_in*)from)->sin_port);
    if(53 != port) {
        return kIOReturnSuccess;
    }
    buffer = *data;
    if(NULL == buffer) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: buffer is null.");
        return kIOReturnSuccess;
    }
    
    while(MBUF_TYPE_DATA != mbuf_type(buffer)) {
        buffer = mbuf_next(buffer);
        if( NULL == buffer) {
            os_log(OS_LOG_DEFAULT, "IOFirewall: cycle through dns is still null.");
            return kIOReturnSuccess;
        }
    }
    
    if(mbuf_len(buffer) <= sizeof(struct DNS_HEADER)) {
        return kIOReturnSuccess;
    }
    
    dns_header = (struct DNS_HEADER*)mbuf_data(buffer);

    if(0 != ntohs(dns_header->rcode)) {
        return kIOReturnSuccess;
    }
    
    if(0 == ntohs(dns_header->ans_count)) {
        return kIOReturnSuccess;
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
    
    

    return kIOReturnSuccess;
}

static errno_t udp_data_out(void *cookie, socket_t so, const struct sockaddr *to, mbuf_t* data, mbuf_t* control, sflt_data_flag_t flags) {
    
    return kIOReturnSuccess;
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
    
    event.timestamp = current_time();
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

long current_time() {
    clock_sec_t seconds;
    clock_usec_t micro;
    
    clock_get_calendar_microtime(&seconds, &micro);
    
    return seconds;
}

firewall_outcome_type determineDecision(cookie_header* header, socket_t local_socket, const struct sockaddr* remote_socket, protocol_type protocol) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: processing connection");
    
    // Send the query then sleep waiting for response.
    query_offset += 1;

    if(in_isolation) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: in quartine, setting it denied");
        header->outcome = ISOLATED;
    }
    
    header->query_id = query_offset;
    send_firewall_query(header, local_socket, remote_socket, protocol);
    
    
    while(header->outcome == UNKNOWN) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: getting state");
        header->outcome = state_get(header->query_id);
        
        if(header->outcome == UNKNOWN) {
            os_log(OS_LOG_DEFAULT, "IOFirewall: going to sleep");
            IOLockLock(state_query_lock);
            int sleep_return = IOLockSleep(state_query_lock, &state_query_lock, THREAD_ABORTSAFE);
            IOLockUnlock(state_query_lock);
            
            os_log(OS_LOG_DEFAULT, "IOFirewall: woken up");
            if(sleep_return != THREAD_AWAKENED) {
                header->outcome = BLOCKED;
            }
            
            if(!filters_registered) {
                // We are shutting down
                header->outcome = ALLOWED;
            }
        }
    }
    
    os_log(OS_LOG_DEFAULT, "IOFirewall: removing state");
    state_rm(header->query_id);
    return header->outcome;
}

bool send_firewall_query(cookie_header* header, socket_t local_socket, const struct sockaddr* remote_socket, protocol_type protocol) {
    firewall_event event = {0};

    struct sockaddr_in local = {0};
    struct sockaddr_in remote = {0};
    
    bzero(&local, sizeof(local));
    bzero(&remote, sizeof(remote));

    if(kIOReturnSuccess != sock_getsockname(local_socket, (struct sockaddr *)&local, sizeof(local))) {
        return false;
    }
    
    if(NULL == remote_socket) {
        // For some reason we don't have a to address yet.
        if( kIOReturnSuccess != sock_getpeername(local_socket, (struct sockaddr *)&remote, sizeof(remote))) {
            return false;
        }
    } else {
        memcpy(&remote, remote_socket, sizeof(remote));
    }

    uuid_copy(event.tag, *header->tag);
    
    event.type = query;
    event.timestamp = current_time();
    event.data.query_event.query_id = header->query_id;
    event.data.query_event.type = protocol;
    event.data.query_event.pid = proc_selfpid();
    event.data.query_event.ppid = proc_selfppid();
    event.data.query_event.local = local;
    event.data.query_event.remote = remote;
    proc_selfname(event.data.query_event.proc_name, PATH_MAX);

    if(!sharedDataQueue->enqueue(&event, sizeof(event))) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: unable to post query into the queue");
    } else {
        os_log(OS_LOG_DEFAULT, "IOFirewall: posted query event");
    }
    

    return true;
}

bool send_tcpconnection_event(cookie_header* header, socket_t local_socket, const struct sockaddr* remote_socket, firewall_outcome_type result, firewall_event_type type) {
    
    firewall_event event = {0};
    
    struct sockaddr_in local = {0};
    struct sockaddr_in remote = {0};
    
    bzero(&local, sizeof(local));
    bzero(&remote, sizeof(remote));
    bzero(&event, sizeof(firewall_event));
    
    if(kIOReturnSuccess != sock_getsockname(local_socket, (struct sockaddr *)&local, sizeof(local))) {
        return false;
    }
    
    if(NULL == remote_socket) {
        // For some reason we don't have a to address yet.
        if( kIOReturnSuccess != sock_getpeername(local_socket, (struct sockaddr *)&remote, sizeof(remote))) {
            return false;
        }
    } else {
        memcpy(&remote, remote_socket, sizeof(remote));
    }
    
    uuid_copy(event.tag, *header->tag);
    event.type = type;
    event.timestamp = current_time();
    event.data.tcp_connection.result = result;
    event.data.tcp_connection.pid = proc_selfpid();
    event.data.tcp_connection.ppid = proc_selfppid();
    event.data.tcp_connection.local = local;
    event.data.tcp_connection.remote = remote;
    proc_selfname(event.data.tcp_connection.proc_name, PATH_MAX);
        
    if(!sharedDataQueue->enqueue(&event, sizeof(event))) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: unable to post event into the queue");
    } else {
        os_log(OS_LOG_DEFAULT, "IOFirewall: posted connect event");
    }
    

    return true;
}

