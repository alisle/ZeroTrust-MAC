//
//  filter.cpp
//  kextfirewall
//
//  Created by Alex Lisle on 6/10/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#include "filter.hpp"

bool filters_registered = false;

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
    return KERN_SUCCESS;
}

static void detach_socket(void *cookie, socket_t so) {
    return;
}

static errno_t connection_out(void *cookie, socket_t so, const struct sockaddr *to) {
    post_kernel_event(so, to);
    return KERN_SUCCESS;
}

static void unregistered(sflt_handle handle) {
    return;
}

static void filter_event(void *cookie, socket_t so, sflt_event_t event, void* param) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: Got filter event");
    return;
}
