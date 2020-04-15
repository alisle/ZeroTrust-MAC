//
//  client.hpp
//  kextfirewall
//
//  Created by Alex Lisle on 6/11/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

#ifndef client_hpp
#define client_hpp

#include <IOKit/IOUserClient.h>
#include <IOKit/IOLib.h>
#include <IOKit/IOKitKeys.h>
#include <os/log.h>

#include "driver.hpp"

#define numberOfMethods 7

extern IOSharedDataQueue* sharedDataQueue;
extern IOMemoryDescriptor* sharedMemoryDescriptor;


class com_notrust_firewall_client : public IOUserClient {
    OSDeclareDefaultStructors(com_notrust_firewall_client)

protected:
    static const IOExternalMethodDispatch sMethods[numberOfMethods];
    com_notrust_firewall_driver* driver;
    
public:
    virtual bool start(IOService* provider) override;
    virtual void stop(IOService* provider) override;
    virtual bool initWithTask(task_t owningTask, void* securityToken, UInt32 type, OSDictionary* properties) override;
    
    virtual IOReturn clientClose(void) override;
    virtual IOReturn clientDied(void) override;
    
protected:
    virtual IOReturn externalMethod(uint32_t selector, IOExternalMethodArguments* arguments, IOExternalMethodDispatch* dispatch, OSObject* target, void* reference);
    
    static IOReturn sEnable(com_notrust_firewall_driver* target, void* reference, IOExternalMethodArguments* arguments);
    
    static IOReturn sDisable(com_notrust_firewall_driver* target, void* reference, IOExternalMethodArguments* arguments);
    
    static IOReturn sQueryDecision(com_notrust_firewall_driver* target, void* reference, IOExternalMethodArguments* arguments);
    
    IOReturn registerNotificationPort(mach_port_t port, UInt32 type, UInt32 ref) override;
    
    IOReturn clientMemoryForType(UInt32 type, IOOptionBits *options, IOMemoryDescriptor** memory) override;
    

};
#endif /* client_hpp */
