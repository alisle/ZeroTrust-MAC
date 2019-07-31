//
//  kext-helpers.c
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#include "include/kext-helpers.h"


char* get_process_name(pid_t pid) {
    char* name = malloc(2048);
    bzero(name, 2048);
    
    proc_name(pid, name, 2048);
    
    if(strlen(name) == 0) {
        return NULL;
    }
    
    return name;
}
