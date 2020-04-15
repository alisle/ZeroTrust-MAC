/* add your code here */
#include "driver.hpp"



IOSharedDataQueue* sharedDataQueue = NULL;
IOMemoryDescriptor* sharedMemoryDescriptor = NULL;

#define super IOService

OSDefineMetaClassAndStructors(com_notrust_firewall_driver, IOService)

OSMallocTag mallocTag;

bool com_notrust_firewall_driver::start(IOService* provider) {
    IOLog("IOFirewall: IOKit Starting");
    os_log(OS_LOG_DEFAULT, "IOFirewall: starting");
    
    if(TRUE != super::start(provider)) {
        return false;
    }
    
    sharedDataQueue = IOSharedDataQueue::withCapacity((DATA_QUEUE_ENTRY_HEADER_SIZE + MAX_QUEUE_SIZE) * sizeof(firewall_event));
    
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
    
    mallocTag = OSMalloc_Tagalloc(BUNDLE_ID, OSMT_DEFAULT);
    if(NULL == mallocTag) {
        return false;
    }

    registerService();
    
    // Initilaize our state engine.
    state_init();
    
    return true;
}

void com_notrust_firewall_driver::stop(IOService* provider) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: stopping");
    unregister_filters();
    
    sharedDataQueue->release();
    sharedDataQueue = NULL;
    
    OSMalloc_Tagfree(mallocTag);
    mallocTag = NULL;
    
    state_release();

    super::stop(provider);
    
}

bool com_notrust_firewall_driver::enable(void) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: enabling firewall");
    if(KERN_SUCCESS != register_filters()) {
        return false;
        
    }
    
    
    return true;
}


void com_notrust_firewall_driver::disable(void) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: disabling firewall");
    unregister_filters();
}


bool com_notrust_firewall_driver::queryDecision(uint32_t query_id, uint32_t decision) {
    os_log(OS_LOG_DEFAULT, "IOFirewall: got a decision");
    // Update the state for this query.
    state_set(query_id, decision);
    
    // Wakeup the thread.
    IOLockWakeup(state_query_lock, &state_query_lock, false);
    
    return true;
}
