//
//  defines.h
//  kextfirewall
//
//  Created by Alex Lisle on 6/11/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#ifndef defines_h
#define defines_h

#define BASE_ID "com.notrust.firewall"
#define BUNDLE_ID "com.notrust.firewall"
#define USER_CLIENT_CLASS "com_notrust_firewall_client"

#define MAX_QUEUE_SIZE 1024

struct fwmessage {
    u_long hash;
    pid_t pid;
    pid_t ppid;
};

typedef struct fwmessage fwmessage;

#endif /* defines_h */
