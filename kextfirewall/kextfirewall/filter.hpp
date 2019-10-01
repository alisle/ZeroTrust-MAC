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

#include "payload.h"
#include "state.hpp"


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

// New inbound connection.
static errno_t connection_in(void *cookie, socket_t so, const struct sockaddr *from);

// New outbound connection.
static errno_t connection_out(void *cookie, socket_t so, const struct sockaddr *to);

static errno_t udp_data_in(void *cookie, socket_t so, const struct sockaddr *from, mbuf_t* data, mbuf_t* control, sflt_data_flag_t flags);
static errno_t udp_data_out(void *cookie, socket_t so, const struct sockaddr *to, mbuf_t* data, mbuf_t* control, sflt_data_flag_t flags);

// When an event happens
static void filter_event(void *cookie, socket_t so, sflt_event_t event, void* param);


// Used to register / unreigster the filters.
kern_return_t register_filters();
kern_return_t unregister_filters();

kern_return_t start_quarantine();
kern_return_t stop_quaratine();

kern_return_t start_isolation();
kern_return_t stop_isolation();

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
    connection_in,
    connection_out,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
};

// socket filer for UDP IPV4
static struct sflt_filter udpFilterIPV4 = {
    UDPIPV4_HANDLE,
    SFLT_GLOBAL,
    (char*)BASE_ID,
    unregistered,
    attach_socket,
    detach_socket,
    NULL,
    NULL,
    NULL,
    udp_data_in,
    udp_data_out,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
};


typedef struct {
    uuid_t* tag;
    uint32_t query_id;
    firewall_outcome_type outcome;
} cookie_header;

// Used to send an outbound event to the queue
bool send_tcpconnection_event(cookie_header* header, socket_t local_socket, const struct sockaddr* remote_socket, firewall_outcome_type result, firewall_event_type type);

// Used to send an event update to the queue.
bool send_update_event(cookie_header* header, sflt_event_t change);

// Used to send a query about allowing the connection.
bool send_firewall_query(cookie_header* header, socket_t local_socket, const struct sockaddr* remote_socket, protocol_type protocol);

// Processes each connection, stating if the connection was allowed or not.
firewall_outcome_type determineDecision(cookie_header* header, socket_t local_socket, const struct sockaddr* remote_socket, protocol_type protocol);


void set_decision(uint32_t query_id, uint32_t decision);

long current_time();

#endif /* filter_hpp */
