/* add your code here */

#include <IOKit/IOService.h>
#include <IOKit/IOUserClient.h>

#ifndef kextfirewall_h
#define kextfirewall_h


#include <os/log.h>
#include <IOKit/IOLib.h>
#include <IOKit/IOSharedDataQueue.h>
#include <IOKit/IODataQueueShared.h>

#include <libkern/OSKextLib.h>
#include <libkern/OSMalloc.h>

#include "filter.hpp"
#include "kern-event.hpp"


class com_notrust_firewall_driver : public IOService
{
    OSDeclareDefaultStructors(com_notrust_firewall_driver)

private:
    
public:
    // IOService Methdos
    virtual bool start(IOService* provider) override;
    virtual void stop(IOService* provider) override;
};

#endif
