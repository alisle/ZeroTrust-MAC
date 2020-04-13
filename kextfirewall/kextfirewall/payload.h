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
#define MAX_PATH_SIZE 4096
#define MAX_DNS_SIZE 1024

typedef enum protocol {
    inbound_udp_v4 = 0,
    outbound_udp_v4 = 1,
    
    inbound_tcp_v4 = 3,
    outbound_tcp_v4 = 4,
    
    inbound_udp_v6 = 5,
    outbound_udp_v6 = 6,

    inbound_tcp_v6 = 7,
    outbound_tcp_v6 = 8,
} protocol_type;

typedef enum {
    outbound_connection = 0,
    accepted_connection = 1,
    connection_update = 2,
    dns_update = 3,
    query = 4,
    socket_listen = 5
} firewall_event_type;

typedef enum {
    ALLOWED = 0,
    BLOCKED = 1,
    QUARANTINED = 2,
    ISOLATED = 3,
    UNKNOWN = 99
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

typedef struct {
    protocol_type type;
    uint32_t query_id;
    int pid;
    int ppid;
    char proc_name[MAX_PATH_SIZE];
    struct sockaddr_in remote;
    struct sockaddr_in local;
} firewall_query;

typedef struct  {
    firewall_outcome_type result;
    int pid;
    int ppid;
    char proc_name[MAX_PATH_SIZE];
    struct sockaddr_in remote;
    struct sockaddr_in local;
} firewall_connection;

typedef struct {
    struct sockaddr_in local;
    int pid;
    int ppid;
    char proc_name[MAX_PATH_SIZE];
} firewall_listen;

typedef struct {
    char dns_message[MAX_DNS_SIZE];
} firewall_dns_update;

typedef union  {
    firewall_connection tcp_connection;
    firewall_event_update_type update_event;
    firewall_dns_update dns_event;
    firewall_query query_event;
    firewall_listen listen;
} firewall_event_data;

typedef struct {
    uuid_t tag;
    long timestamp;
    firewall_event_type type;
    firewall_event_data data;
} firewall_event;

#endif /* payload_h */
