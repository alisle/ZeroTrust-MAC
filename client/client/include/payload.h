//
//  payload.h
//  reporter
//
//  Created by Alex Lisle on 6/8/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#ifndef payload_h
#define payload_h

#include <netinet/in.h>


struct payload {
    int pid;
    int ppid;
    struct sockaddr_in remote;
    struct sockaddr_in local;
};

typedef struct payload payload;

typedef enum {
    outbound_connection = 0,
    inbound_connection = 1,
    connection_update = 2,
    dns_update = 3
} firewall_event_type;

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
    int pid;
    int ppid;
    struct sockaddr_in remote;
    struct sockaddr_in local;
} firewall_connection_out;

typedef struct {
    char dns_message[1024];
} firewall_dns_update;

typedef union  {
    firewall_connection_out outbound;
    firewall_event_update_type update_event;
    firewall_dns_update dns_event;
} firewall_event_data;

typedef struct {
    uuid_t tag;
    firewall_event_type type;
    firewall_event_data data;
} firewall_event;

#endif /* payload_h */
