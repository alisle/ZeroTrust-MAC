//
//  client.cpp
//  kextfirewall
//
//  Created by Alex Lisle on 6/11/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#include "client.hpp"



#define super IOUserClient


OSDefineMetaClassAndStructors(com_notrust_firewall_client, IOUserClient)
const IOExternalMethodDispatch com_notrust_firewall_client::sMethods[numberOfMethods] = {
    {
        (IOExternalMethodAction)&com_notrust_firewall_client::sEnable,
        0, // Number of scalar arguments
        0, // NUmber of Struct Arguments
        1, // Number of outputs
        0, // Numbers of struct out values.
    },
    {
        (IOExternalMethodAction)&com_notrust_firewall_client::sDisable,
        0,
        0,
        0,
        0,
    },
    {
        (IOExternalMethodAction)&com_notrust_firewall_client::sQuarantineEnable,
        0, // Number of scalar arguments
        0, // NUmber of Struct Arguments
        1, // Number of outputs
        0, // Numbers of struct out values.
    },
    {
        (IOExternalMethodAction)&com_notrust_firewall_client::sQuarantineDisable,
        0, // Number of scalar arguments
        0, // NUmber of Struct Arguments
        1, // Number of outputs
        0, // Numbers of struct out values.
    },
    {
        (IOExternalMethodAction)&com_notrust_firewall_client::sIsolateEnable,
        0, // Number of scalar arguments
        0, // NUmber of Struct Arguments
        1, // Number of outputs
        0, // Numbers of struct out values.
    },
    {
        (IOExternalMethodAction)&com_notrust_firewall_client::sIsolateDisable,
        0, // Number of scalar arguments
        0, // NUmber of Struct Arguments
        1, // Number of outputs
        0, // Numbers of struct out values.
    },
    {
        (IOExternalMethodAction)&com_notrust_firewall_client::sQueryDecision,
        2, // Number of scalar arguments
        0, // NUmber of Struct Arguments
        0, // Number of outputs
        0, // Numbers of struct out values.
    }
};

bool com_notrust_firewall_client::start(IOService* provider) {
    
    if(kIOReturnSuccess != OSKextRetainKextWithLoadTag(OSKextGetCurrentLoadTag())) {
     return false;
    }
     
    driver = OSDynamicCast(com_notrust_firewall_driver, provider);
    if( NULL != driver ) {
        return IOUserClient::start(provider);
    }
    
    return false;
}

void com_notrust_firewall_client:: stop(IOService* provider) {
    
    super::stop(provider);
}

bool com_notrust_firewall_client::initWithTask(task_t owningTask
                                                      , void *securityToken
                                                      , UInt32 type
                                                      , OSDictionary *properties) {
    
    super::initWithTask(owningTask, securityToken, type, properties);
    return true;
}

IOReturn com_notrust_firewall_client::clientClose(void) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: closing client");
    if(driver != NULL) {
        driver->disable();
    }
    
    terminate();
    
    
    return kIOReturnSuccess;
}

IOReturn com_notrust_firewall_client::clientDied() {
    os_log(OS_LOG_DEFAULT, "IOFirewall: client died");
    return super::clientDied();
}

IOReturn com_notrust_firewall_client::externalMethod(uint32_t selector, IOExternalMethodArguments *arguments, IOExternalMethodDispatch* dispatch, OSObject* target, void* reference) {
 
    if( selector < (uint32_t)numberOfMethods) {
        dispatch = (IOExternalMethodDispatch*)&sMethods[selector];
        if(!target) {
            target = driver;
        }
    }
    
    return super::externalMethod(selector, arguments, dispatch, target, reference);
}

IOReturn com_notrust_firewall_client::sEnable(com_notrust_firewall_driver* target, void* reference, IOExternalMethodArguments *arguments) {
    bool status = target->enable();
    arguments->scalarOutput[0] = status;
    return kIOReturnSuccess;
}

IOReturn com_notrust_firewall_client::sDisable(com_notrust_firewall_driver *target
                                               , void *reference
                                               , IOExternalMethodArguments *arguments) {
    target->disable();
    return kIOReturnSuccess;
}

IOReturn com_notrust_firewall_client::sQuarantineEnable(com_notrust_firewall_driver* target, void* reference, IOExternalMethodArguments* arguments) {
    bool status = target->startQuarantine();
    arguments->scalarOutput[0] = status;
    
    return kIOReturnSuccess;
}

IOReturn com_notrust_firewall_client::sQuarantineDisable(com_notrust_firewall_driver* target, void* reference, IOExternalMethodArguments* arguments) {
    bool status = target->stopQuarantine();
    arguments->scalarOutput[0] = status;
    
    return kIOReturnSuccess;
}

IOReturn com_notrust_firewall_client::sIsolateEnable(com_notrust_firewall_driver* target, void* reference, IOExternalMethodArguments* arguments) {
    bool status = target->startIsolate();
    arguments->scalarOutput[0] = status;
    
    return kIOReturnSuccess;
}

IOReturn com_notrust_firewall_client::sIsolateDisable(com_notrust_firewall_driver* target, void* reference, IOExternalMethodArguments* arguments) {
    bool status = target->stopIsolate();
    arguments->scalarOutput[0] = status;
    
    return kIOReturnSuccess;
}


IOReturn com_notrust_firewall_client::sQueryDecision(com_notrust_firewall_driver* target, void* reference, IOExternalMethodArguments* arguments) {
    
    uint32_t query_id = (uint32_t)arguments->scalarInput[0];
    uint32_t decision = (uint32_t)arguments->scalarInput[1];
    
    target->queryDecision(query_id, decision);
    
    return kIOReturnSuccess;
}


IOReturn com_notrust_firewall_client::registerNotificationPort(mach_port_t port, UInt32 type, UInt32 ref) {
    
    if((NULL == sharedDataQueue) || (MACH_PORT_NULL == port)) {
        return kIOReturnError;
    }
    
    sharedDataQueue->setNotificationPort(port);
    return kIOReturnSuccess;
}

IOReturn com_notrust_firewall_client::clientMemoryForType(UInt32 type, IOOptionBits *options, IOMemoryDescriptor **memory) {
    *memory = NULL;
    *options = 0;
    
    if(kIODefaultMemoryType != type) {
        return kIOReturnNoMemory;
    }
    
    if( NULL == sharedMemoryDescriptor) {
        return kIOReturnNoMemory;
    }
    
    sharedMemoryDescriptor->retain();
    
    *memory = sharedMemoryDescriptor;
    
    return kIOReturnSuccess;
}
