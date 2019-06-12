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

#include "driver.hpp"

#define numberOfMethods 1

class com_notrust_firewall_client : public IOUserClient {
    OSDeclareDefaultStructors(com_notrust_firewall_client)

protected:
    static const IOExternalMethodDispatch sMethods[numberOfMethods];
    
public:
    virtual bool start(IOService* provider) override;
    virtual void stop(IOService* provider) override;
    virtual bool initWithTask(task_t owningTask, void* securityToken, UInt32 type, OSDictionary* properties) override;
    
protected:
    virtual IOReturn externalMethod(uint32_t selector, IOExternalMethodArguments* arguments, IOExternalMethodDispatch* dispatch, OSObject* target, void* reference);
    
    static IOReturn sTestMe(com_notrust_firewall_driver* target, void* refefrence, IOExternalMethodArguments* arguments);
};
#endif /* client_hpp */
