//
//  state.hpp
//  kextfirewall
//
//  Created by Alex Lisle on 9/18/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#ifndef state_hpp
#define state_hpp

#include <IOKit/IOLib.h>
#include <libkern/c++/OSDictionary.h>
#include <libkern/c++/OSNumber.h>
#include <os/log.h>

extern "C" {
#include "payload.h"
}

bool state_init();
void state_release();
bool state_set(uint32_t query_id, uint32_t decision);
void state_rm(uint32_t query_id);

firewall_outcome_type state_get(u_int32_t query_id);
#endif /* state_hpp */
