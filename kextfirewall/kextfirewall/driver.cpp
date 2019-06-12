/* add your code here */
#include "driver.hpp"


OSMallocTag mallocTag = NULL;

IOSharedDataQueue *sharedDataQueue = NULL;

#define super IOService

OSDefineMetaClassAndStructors(com_notrust_firewall_driver, IOService)

bool com_notrust_firewall_driver::start(IOService* provider) {
    IOLog("IOFirewall: IOKit Starting");
    os_log(OS_LOG_DEFAULT, "IOFirewall: starting");
    
    if(TRUE != super::start(provider)) {
        return false;
    }
    
    mallocTag = OSMalloc_Tagalloc(BUNDLE_ID, OSMT_DEFAULT);
    if(NULL == mallocTag) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: Failed creating tag for malloc calls");
        return false;
    }
    
    sharedDataQueue = IOSharedDataQueue::withCapacity((DATA_QUEUE_ENTRY_HEADER_SIZE + MAX_QUEUE_SIZE) * sizeof(fwmessage));
    
    if(NULL == sharedDataQueue) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: Unable to created shared data queue");
        return false;
    }
    
    setProperty("IOUserClientClass", USER_CLIENT_CLASS);
    
    /*
    if(kIOReturnSuccess != OSKextRetainKextWithLoadTag(OSKextGetCurrentLoadTag())) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: load tag failed");
        return false;
    }
    */
    
    registerService();
    
    register_filters();
    register_kernelevents();
    
    return true;
}

void com_notrust_firewall_driver::stop(IOService* provider) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: starting");
    unregister_filters();
    
    sharedDataQueue->release();
    sharedDataQueue = NULL;
    
    OSMalloc_Tagfree(mallocTag);
    mallocTag = NULL;
    
    super::stop(provider);
    
}

