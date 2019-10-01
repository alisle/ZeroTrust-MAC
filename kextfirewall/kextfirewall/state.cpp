//
//  state.cpp
//  kextfirewall
//
//  Created by Alex Lisle on 9/18/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#include "state.hpp"

OSDictionary* state_lookup = NULL;
IOLock* state_lock = NULL;
IOLock* state_query_lock = NULL;

bool state_initialized = false;

bool state_init() {
    os_log(OS_LOG_DEFAULT, "IOFirewall: initializing state");
    state_query_lock = IOLockAlloc();
    
    if(state_query_lock == NULL) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: failed to init state_query_lock");
        return false;
    }
    
    state_lock = IOLockAlloc();
    
    if(state_lock == NULL) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: failed to init state_lock");
        return false;
    }
    
    
    state_lookup = OSDictionary::withCapacity(1024);
    state_initialized = true;
    
    return state_initialized;
}


bool state_set(uint32_t query_id, uint32_t decision) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: setting state %u->%u", query_id, decision);

    char key[32] = {0};
    snprintf(key, sizeof(key), "%u", query_id);
    OSNumber* state_decision = NULL;
    state_decision = OSNumber::withNumber(decision, sizeof(u_int32_t));
    
    if( state_decision == NULL ) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: failed to set state");
        return false;
    }
    
    IOLockLock(state_lock);
    state_lookup->setObject(key, state_decision);
    IOLockUnlock(state_lock);
    
    return true;
}

firewall_outcome_type state_get(u_int32_t query_id) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: looking up %u", query_id);

    char key[32] = {0};
    snprintf(key, sizeof(key), "%u", query_id);
    OSNumber* state_decision = NULL;
    
    IOLockLock(state_lock);
    state_decision = OSDynamicCast(OSNumber, state_lookup->getObject(key));
    IOLockUnlock(state_lock);
    
    
    if(state_decision == NULL) {
        return UNKNOWN;
    } else {
        return static_cast<firewall_outcome_type>(state_decision->unsigned32BitValue());
    }
}

void state_rm(uint32_t query_id) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: removing state");

    char key[32] = {0};
    snprintf(key, sizeof(key), "%u", query_id);

    IOLockLock(state_lock);
    state_lookup->removeObject(key);
    IOLockUnlock(state_lock);
}

void state_release() {
    if(state_lookup != NULL) {
        state_lookup->release();
        state_lookup  = NULL;
    }
    
    if( state_lock != NULL) {
        IOLockFree(state_lock);
        state_lock = NULL;
    }
    
    if( state_query_lock != NULL) {
        IOLockFree(state_query_lock);
        state_query_lock = NULL;
    }
}
