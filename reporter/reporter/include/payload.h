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
#endif /* payload_h */
