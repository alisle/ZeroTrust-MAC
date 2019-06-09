//
//  kern-event.h
//  reporter
//
//  Created by Alex Lisle on 6/8/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#ifndef kern_event_h
#define kern_event_h

#include <stdio.h>
#include <os/log.h>
#include <sys/kern_event.h>
#include <sys/ioctl.h>
#include <sys/proc_info.h>

#include "payload.h"

int create_socket(void);
payload* get_kern_message(int fd);
char* get_process_name(pid_t pid);

#endif /* kern_event_h */
