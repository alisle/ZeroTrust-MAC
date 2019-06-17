/* add your code here */
#include "driver.hpp"


OSMallocTag mallocTag = NULL;

IOSharedDataQueue* sharedDataQueue = NULL;
IOMemoryDescriptor* sharedMemoryDescriptor = NULL;

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
    
    sharedMemoryDescriptor = sharedDataQueue->getMemoryDescriptor();
    if(NULL == sharedMemoryDescriptor) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: Unable to get memory descriptor for shared data queue!");
        return false;
    }
    
    setProperty("IOUserClientClass", USER_CLIENT_CLASS);
    
    /*
    if(kIOReturnSuccess != OSKextRetainKextWithLoadTag(OSKextGetCurrentLoadTag())) {
        os_log(OS_LOG_DEFAULT, "IOFirewall: load tag failed");
        return false;
    }
    */
    enable();
    registerService();
    
    return true;
}

void com_notrust_firewall_driver::stop(IOService* provider) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: stoping");
    unregister_filters();
    
    sharedDataQueue->release();
    sharedDataQueue = NULL;
    
    OSMalloc_Tagfree(mallocTag);
    mallocTag = NULL;
    
    super::stop(provider);
    
}

bool com_notrust_firewall_driver::enable(void) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: enabling firewall");
    if(KERN_SUCCESS != register_filters()) {
        return false;
        
    }
    
    if(KERN_SUCCESS != register_kernelevents()) {
        return false;
    }
    
    return true;
}


void com_notrust_firewall_driver::disable(void) {
    unregister_filters();
}
