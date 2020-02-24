//
//  kext-helpers.c
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

// #include "include/kext-helpers.h"
#include <stdio.h>
#include <sys/proc.h>
#include <sys/proc_info.h>
#include <sys/ioctl.h>
#include <strings.h>
#include <stdlib.h>
#include <libproc.h>


char* get_process_name(pid_t pid) {
    char* name = malloc(2048);
    bzero(name, 2048);
    
    proc_name(pid, name, 2048);
    
    if(strlen(name) == 0) {
        return NULL;
    }
    
    return name;
}


char* get_proc_path(pid_t pid) {
    char* path = malloc(2048);
    bzero(path, 2048);
    
    if(proc_pidpath (pid, path, 2048) <= 0) {
        return NULL;
    }
    
    return path;
}

