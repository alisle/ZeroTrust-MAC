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

extern "C" {
#include "payload.h"
#include "defines.h"
}


class com_notrust_firewall_driver : public IOService
{
    OSDeclareDefaultStructors(com_notrust_firewall_driver)

private:
    
public:
    // IOService Methdos
    virtual bool start(IOService* provider) override;
    virtual void stop(IOService* provider) override;
    
    bool enable(void);
    void disable(void);
    
    bool startQuarantine(void);
    bool stopQuarantine(void);
    
    bool startIsolate(void);
    bool stopIsolate(void);
};

#endif
