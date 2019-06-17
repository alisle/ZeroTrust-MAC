//
//  filter.cpp
//  kextfirewall
//
//  Created by Alex Lisle on 6/10/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#include "filter.hpp"

#include <libkern/OSMalloc.h>

bool filters_registered = false;

extern IOSharedDataQueue* sharedDataQueue;
extern OSMallocTag mallocTag;


kern_return_t register_filters() {
    os_log(OS_LOG_DEFAULT, "IOFirewall: registering socket filters");
    if(filters_registered) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: filters were already registered, skipping");
        return KERN_SUCCESS;
    }
    
    
    kern_return_t result = sflt_register(&tcpFilterIPV4, AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if(KERN_SUCCESS != result) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: unable to reigster filters!");
        filters_registered = false;
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
            os_log(OS_LOG_DEFAULT, "IOFirewall: unable to unregister filters!");
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
    }
    

    return true;
}
