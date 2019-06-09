//
//  firewall.c
//  firewall
//
//  Created by Alex Lisle on 6/6/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#include <mach/mach_types.h>
#include <sys/proc.h>
#include <sys/socket.h>
#include <sys/kpi_socketfilter.h>
#include <sys/kpi_socket.h>
#include <IOKit/IOReturn.h>
#include <netinet/in.h>
#include <IOKit/IOLib.h>
#include <os/log.h>
#include <sys/kern_event.h>
#include <unistd.h>

#define BASE_ID "com.notrust.firewall"

#define BASE_HANDLE 0x1C14325F

#define TCPIPV4_HANDLE BASE_HANDLE + 1
#define UDPIPV4_HANDLE BASE_HANDLE + 2

// used to populate KEvent ID.
u_int32_t kev_id = 0;

// Entry Point for the FW
kern_return_t firewall_start(kmod_info_t * ki, void *d);

// Exit Point for the FW
kern_return_t firewall_stop(kmod_info_t *ki, void *d);

// Prototype for callback when a socket has been detached.
static void detach_socket(void *cookie, socket_t so);

// Prototype for callback when a socket has been attached.
static errno_t attach_socket(void **cookie, socket_t so);

// Call back when uregistering filter.
static void unregistered(sflt_handle handle);

// New outbound connection.
static errno_t connection_out(void *cookie, socket_t so, const struct sockaddr *to);

// Used to post a kernel event regarding a new connection.
bool post_kernel_event(socket_t so, const struct sockaddr *to);

// Used to register for kernel events.
kern_return_t register_kernelevents();

// Used to register / unreigster the filters.
kern_return_t register_filters();
kern_return_t unregister_filters();


//socket filter, TCP IPV4
static struct sflt_filter tcpFilterIPV4 = {
    TCPIPV4_HANDLE,
    SFLT_GLOBAL,
    (char*)BASE_ID,
    unregistered,
    attach_socket,
    detach_socket,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    connection_out,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
};


kern_return_t firewall_start(kmod_info_t * ki, void *d)
{
    os_log(OS_LOG_DEFAULT, "ZeroTrustFirewall: starting");
    if(KERN_SUCCESS != register_kernelevents()) {
        return KERN_FAILURE;
    }
    
    if(KERN_SUCCESS != register_filters()) {
        return KERN_FAILURE;
    }
       
    return KERN_SUCCESS;
}

kern_return_t firewall_stop(kmod_info_t *ki, void *d)
{
    os_log(OS_LOG_DEFAULT, "ZeroTrustFirewall: stopping");
    return unregister_filters();
}


/// Registering Functions.
kern_return_t register_kernelevents() {
    os_log(OS_LOG_DEFAULT, "ZeroTrustFirewall: registering for kernel events");
    kern_return_t result = KERN_FAILURE;
    
    result = kev_vendor_code_find(BASE_ID, &kev_id);
    if(result != KERN_SUCCESS) {
        os_log(OS_LOG_DEFAULT, "ZeroTrustFirewall: unable to define ID for kernel events");
    }
    
    return result;
}

kern_return_t register_filters() {
    os_log(OS_LOG_DEFAULT, "ZeroTrustFirewall: registering socket filters");
    kern_return_t result = sflt_register(&tcpFilterIPV4, AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if(KERN_SUCCESS != result) {
        os_log(OS_LOG_DEFAULT, "ZeroTrustFirewall: unable to reigster filters!");
    }
    
    return result;
}

kern_return_t unregister_filters() {
    os_log(OS_LOG_DEFAULT, "ZeroTrustFirewall: unregistering socket filters");
    kern_return_t status = sflt_unregister(TCPIPV4_HANDLE);
    if(KERN_SUCCESS != status) {
        os_log(OS_LOG_DEFAULT, "ZeroTrustFirewall: unable to unregister filters!");
    }
    
    return status;
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

// Kernel Event Functions.
bool post_kernel_event(socket_t so, const struct sockaddr *to) {
    int pid = proc_selfpid();
    int ppid = proc_selfppid();
    int euid = geteuid();
    int uid = getuid();
    
    struct sockaddr_in  local = {0};
    struct sockaddr_in remote = {0};
    struct kev_msg event = {0};
    
    bzero(&local, sizeof(local));
    bzero(&remote, sizeof(remote));
    bzero(&event, sizeof(event));
    
    
    if(KERN_SUCCESS != sock_getsockname(so, (struct sockaddr *)&local, sizeof(local))) {
        os_log(OS_LOG_DEFAULT, "ZeroTrustFirewall: unable to get socket name");
        return false;
    }
    
    if(NULL == to) {
        // For some reason we don't have a to address yet.
        if( KERN_SUCCESS != sock_getpeername(so, (struct sockaddr *)&remote, sizeof(remote))) {
            os_log(OS_LOG_DEFAULT, "ZeroTrustFirewall: unable to get socket peer name");
            return false;
        }
    } else {
        memcpy(&remote, to, sizeof(remote));
    }
    
    os_log(OS_LOG_DEFAULT, "ZeroTrustFirewall: PID: %u, PPID: %u", pid, ppid);
    
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
    
    event.dv[4].data_length = sizeof(uid);
    event.dv[4].data_ptr = &uid;
    
    event.dv[5].data_length = sizeof(euid);
    event.dv[5].data_ptr = &euid;
    
    if(KERN_SUCCESS != kev_msg_post(&event)) {
        os_log(OS_LOG_DEFAULT, "ZeroTrustFirewall: unable to posst kernel event");
        return false;
    }
    
    return true;
}
