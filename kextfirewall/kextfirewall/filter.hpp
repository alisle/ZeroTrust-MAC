//
//  filter.hpp
//  kextfirewall
//
//  Created by Alex Lisle on 6/10/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#ifndef filter_hpp
#define filter_hpp

#include <stddef.h>
#include <sys/socket.h>
#include <sys/kpi_socketfilter.h>
#include <sys/kpi_socket.h>
#include <netinet/in.h>
#include <sys/kern_event.h>
#include <mach/mach_types.h>
#include <os/log.h>
#include <sys/proc.h>
#include <sys/random.h>
#include <uuid/uuid.h>


#include <IOKit/IOSharedDataQueue.h>
#include <IOKit/IODataQueueShared.h>

#include "kern-event.hpp"
#include "payload.h"


#define BASE_ID "com.notrust.firewall"

#define BASE_HANDLE 0x1C14325F

#define TCPIPV4_HANDLE BASE_HANDLE + 1
#define UDPIPV4_HANDLE BASE_HANDLE + 2

// Prototype for callback when a socket has been detached.
static void detach_socket(void *cookie, socket_t so);

// Prototype for callback when a socket has been attached.
static errno_t attach_socket(void **cookie, socket_t so);

// Call back when uregistering filter.
static void unregistered(sflt_handle handle);

// New outbound connection.
static errno_t connection_out(void *cookie, socket_t so, const struct sockaddr *to);

// When an event happens
static void filter_event(void *cookie, socket_t so, sflt_event_t event, void* param);


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
    filter_event,
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


typedef struct {
    uuid_t* tag;
} cookie_header;

// Used to send an outbound event to the queue
bool send_outbound_event(cookie_header* header, socket_t so, const struct sockaddr *to);

// Used to send an event update to the queue.
bool send_update_event(cookie_header* header, sflt_event_t change);
#endif /* filter_hpp */
