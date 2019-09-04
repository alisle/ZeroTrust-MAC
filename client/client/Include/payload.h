//
//  payload.h
//  reporter
//
//  Created by Alex Lisle on 6/8/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#ifndef payload_h
#define payload_h

#include <limits.h>
#include <netinet/in.h>


typedef enum {
    outbound_connection = 0,
    inbound_connection = 1,
    connection_update = 2,
    dns_update = 3
} firewall_event_type;

typedef enum {
    ALLOWED = 0,
    BLOCKED = 1,
    QUARANTINED = 2,
    ISOLATED = 3
} firewall_outcome_type;

typedef enum {
    connecting = 1,
    connected = 2,
    disconnecting = 3,
    disconnected = 4,
    read_socket_flushed = 5,
    socket_shutdown = 6,
    can_not_recieve_more = 7,
    can_not_send_more = 8,
    closing = 9,
    bound = 10
} firewall_event_update_type;

typedef struct  {
    firewall_outcome_type result;
    int pid;
    int ppid;
    char proc_name[PATH_MAX];
    struct sockaddr_in remote;
    struct sockaddr_in local;
} firewall_connection;

typedef struct {
    char dns_message[1024];
} firewall_dns_update;

typedef union  {
    firewall_connection tcp_connection;
    firewall_event_update_type update_event;
    firewall_dns_update dns_event;
} firewall_event_data;

typedef struct {
    uuid_t tag;
    long timestamp;
    firewall_event_type type;
    firewall_event_data data;
} firewall_event;

#endif /* payload_h */
