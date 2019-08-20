//
//  kext-helpers.h
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#ifndef kext_helpers_h
#define kext_helpers_h

#include <stdio.h>
#include <os/log.h>
#include <sys/kern_event.h>
#include <sys/ioctl.h>
#include <sys/proc_info.h>

#include <IOKit/IODataQueueClient.h>
#include <IOKit/IODataQueueShared.h>

#include "payload.h"

char* get_process_name(pid_t pid);

#endif /* kext_helpers_h */
