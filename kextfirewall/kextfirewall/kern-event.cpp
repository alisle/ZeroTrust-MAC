//
//  kern-event.cpp
//  kextfirewall
//
//  Created by Alex Lisle on 6/11/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#include "kern-event.hpp"

// used to populate KEvent ID.
u_int32_t kev_id = 0;


kern_return_t register_kernelevents() {
    os_log(OS_LOG_DEFAULT, "IOFirewall: registering for kernel events");
    kern_return_t result = KERN_FAILURE;
    
    result = kev_vendor_code_find(BASE_ID, &kev_id);
    if(result != KERN_SUCCESS) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: unable to define ID for kernel events");
    }
    
    return result;
}

bool post_kernel_event(socket_t so, const struct sockaddr *to) {
    int pid = proc_selfpid();
    int ppid = proc_selfppid();
    
    struct sockaddr_in  local = {0};
    struct sockaddr_in remote = {0};
    struct kev_msg event = {0};
    
    bzero(&local, sizeof(local));
    bzero(&remote, sizeof(remote));
    bzero(&event, sizeof(event));
    
    
    if(KERN_SUCCESS != sock_getsockname(so, (struct sockaddr *)&local, sizeof(local))) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: unable to get socket name");
        return false;
    }
    
    if(NULL == to) {
        // For some reason we don't have a to address yet.
        if( KERN_SUCCESS != sock_getpeername(so, (struct sockaddr *)&remote, sizeof(remote))) {
            os_log(OS_LOG_DEFAULT, "IOFirewall: unable to get socket peer name");
            return false;
        }
    } else {
        memcpy(&remote, to, sizeof(remote));
    }
        
    event.vendor_code = kev_id;
    event.kev_class = KEV_ANY_CLASS;
    event.kev_subclass = KEV_ANY_SUBCLASS;
    
    event.event_code = 0;
    
    event.dv[0].data_length = sizeof(int);
    event.dv[0].data_ptr = &pid;
    
    event.dv[1].data_length = sizeof(int);
    event.dv[1].data_ptr = &ppid;
    
    event.dv[2].data_length = sizeof(local);
    event.dv[2].data_ptr = &local;
    
    event.dv[3].data_length = sizeof(remote);
    event.dv[3].data_ptr = &remote;
    
    
    if(KERN_SUCCESS != kev_msg_post(&event)) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: unable to posst kernel event");
        return false;
    }
    
    return true;
}

