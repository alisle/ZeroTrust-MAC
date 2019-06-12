//
//  kern-event.hpp
//  kextfirewall
//
//  Created by Alex Lisle on 6/11/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#ifndef kern_event_hpp
#define kern_event_hpp

extern "C" {
#include <sys/kern_event.h>
#include <mach/mach_types.h>
#include <os/log.h>
#include <sys/socket.h>
#include <sys/proc.h>
#include <netinet/in.h>
#include <string.h>
    
}

#include "defines.h"

// Used to register for kernel events.
kern_return_t register_kernelevents();



// Used to post a kernel event regarding a new connection.
bool post_kernel_event(socket_t so, const struct sockaddr *to);

#endif /* kern_event_hpp */
