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
        (IOExternalMethodAction)&com_notrust_firewall_client::sTestMe,
        0, // Number of scalar arguments
        0, // NUmber of Struct Arguments
        1, // Number of outputs
        0, // Numbers of struct out values.
    }
};

bool com_notrust_firewall_client::start(IOService* provider) {
    return IOUserClient::start(provider);
}

bool com_notrust_firewall_client::initWithTask(task_t owningTask
                                                      , void *securityToken
                                                      , UInt32 type
                                                      , OSDictionary *properties) {
    
    super::initWithTask(owningTask, securityToken, type, properties);
    return true;
}

void com_notrust_firewall_client:: stop(IOService* provider) {
    super::stop(provider);
}

IOReturn com_notrust_firewall_client::externalMethod(uint32_t selector, IOExternalMethodArguments *arguments, IOExternalMethodDispatch* dispatch, OSObject* target, void* reference) {
 
    if( selector < (uint32_t)numberOfMethods) {
        dispatch = (IOExternalMethodDispatch*)&sMethods[selector];
    }
    
    return super::externalMethod(selector, arguments, dispatch, target, reference);
}

IOReturn com_notrust_firewall_client::sTestMe(com_notrust_firewall_driver* target, void* reference, IOExternalMethodArguments* arguments) {
    arguments->scalarOutput[0] = 1;
    
    return kIOReturnSuccess;
}

