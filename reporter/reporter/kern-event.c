//
//  kern-event.c
//  reporter
//
//  Created by Alex Lisle on 6/8/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#include "include/kern-event.h"


#define BASE_ID "com.notrust.firewall"

int create_socket() {
    int system_socket = -1;
    struct kev_vendor_code code = {0};
    struct kev_request request = {0};
    
    system_socket = socket(PF_SYSTEM, SOCK_RAW, SYSPROTO_EVENT);
    if( -1 == system_socket) {
        os_log(OS_LOG_DEFAULT, "ZeroTrustListener: unable to create system socket");
        return system_socket;
    }
    
    strncpy(code.vendor_string, BASE_ID, KEV_VENDOR_CODE_MAX_STR_LEN);
    if(0 != ioctl(system_socket, SIOCGKEVVENDOR, &code)) {
        os_log(OS_LOG_DEFAULT, "ZeroTrustListener: unable to retrieve vendor code");
        return -1;
    }
    
    request.vendor_code = code.vendor_code;
    request.kev_subclass = KEV_ANY_CLASS;
    
    if( 0 != ioctl(system_socket, SIOCSKEVFILT, &request)) {
        os_log(OS_LOG_DEFAULT, "ZeroTrustListener: unable to set query");
        return -1;
    }
    
    return system_socket;
}

payload* get_kern_message(int fd) {
    char message_buffer[1024] = {0};
    struct kern_event_msg *event_message = {0};
    
    ssize_t bytes_recieved = recv(fd, message_buffer, sizeof(message_buffer), 0);
    event_message = (struct kern_event_msg*)message_buffer;
    
    if(bytes_recieved != event_message->total_size) {
        os_log(OS_LOG_DEFAULT, "invalid size (%lu:%u)\n", bytes_recieved, event_message->total_size);
        return NULL;
    }

    payload* message = malloc(sizeof(payload));
    payload* event_message_payload = (payload*)&event_message->event_data[0];
    message->pid = event_message_payload->pid;
    message->ppid = event_message_payload->ppid;
    message->local = event_message_payload->local;
    message->remote = event_message_payload->remote;
    
    return message;

}

char* get_process_name(pid_t pid) {
    char* name = malloc(2048);
    bzero(name, 2048);
    
    proc_name(pid, name, 2048);
    
    if(strlen(name) == 0) {
        return NULL;
    }
    
    return name;
}
