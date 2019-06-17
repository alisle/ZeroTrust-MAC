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
    connection_update = 2
} firewall_event_type;

typedef struct  {
    int pid;
    int ppid;
} firewall_connection_out;

typedef union  {
    firewall_connection_out outbound;
} firewall_event_data;

typedef struct {
    firewall_event_type type;
    firewall_event_data data;
} firewall_event;

#endif /* payload_h */
