//
//  KernComm.swift
//  reporter
//
//  Created by Alex Lisle on 6/12/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

class KernComm {
    private var notificationPortOpen = false
    private var notificationMemory : mach_vm_address_t = 0
    private var notificationMemorySize : mach_vm_size_t = 0
    private var notificationPort : mach_port_t = 0
    
    private var isOpen = false;
    private var connection : io_connect_t = 0
    private var service : io_service_t = 0
    
    private var queue : UnsafeMutablePointer<IODataQueueMemory>? = nil;
    
    func open() -> Bool {
        if isOpen {
            return true
        }
        
        service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("com_notrust_firewall_driver"))
        
        if service == 0 {
            print("unable to find service")
            return false
        }
        
        if kIOReturnSuccess != IOServiceOpen(service, mach_task_self_, 0, &connection) {
            print("unable to open service")
            IOObjectRelease(service)
            service = 0
            isOpen = false
        } else {
            isOpen = true
        }
        
        print("successfully opened service")
        return isOpen
    }
    
    func close() {
        if !isOpen {
            return
        }
        
        IOServiceClose(connection)
        IOObjectRelease(service)
        connection = 0
        service = 0
        isOpen = false
    }
    
    func createNotificationPort() -> Bool {
        if notificationPortOpen {
            return true
        }
        
        notificationPort = IODataQueueAllocateNotificationPort()
        if notificationPort == 0 {
            print("unable to create notification port!")
            return false
        }
        
        if kIOReturnSuccess != IOConnectSetNotificationPort(connection, 0x1, notificationPort, 0x0)  {
            print("unable to set notication port!")
            return false
        }
        
        
        if kIOReturnSuccess != IOConnectMapMemory(connection,
                                                  UInt32(kIODefaultMemoryType),
                                                  mach_task_self_,
                                                  &notificationMemory,
                                                  &notificationMemorySize,
                                                  IOOptionBits(kIOMapAnywhere)) {
            print("unable to map memory")
            return false
        }
        
        notificationPortOpen = true
        queue = UnsafeMutablePointer<IODataQueueMemory>.init(bitPattern: UInt(notificationMemory))
        
        return true
    }
    
    func destroyNotificationPort() {
        if !notificationPortOpen {
            return
        }
        
        if kIOReturnSuccess != IOConnectUnmapMemory(connection, UInt32(kIODefaultMemoryType), mach_task_self_, notificationMemory) {
            print("Unable to unmap memory, this isn't good")
        }
        
        notificationPortOpen = false
        
    }
    
    func hasData() -> Bool {
        if IODataQueueDataAvailable(queue) {
            return true
        }
        
        return false
    }
    
    func dequeue() -> Optional<FirewallEvent> {
        var size : UInt32 = UInt32(MemoryLayout<firewall_event>.size)
        var buffer = firewall_event()
        
        if kIOReturnSuccess != IODataQueueDequeue(queue, &buffer, &size) {
            print("Unable to dequeue data")
            return Optional.none
        }
        
        
        switch buffer.type {
        case outbound_connection:
            let uuid = UUID.init(uuid: buffer.tag)
            let pid = buffer.data.outbound.pid;
            let ppid = buffer.data.outbound.ppid;
            guard let remote =  Helpers.getHostInformation(sockaddr: &buffer.data.outbound.remote) else {
                return Optional.none
            }
            
            guard let local = Helpers.getHostInformation(sockaddr: &buffer.data.outbound.local) else {
                return Optional.none
            }
            
            
                        
            return FirewallConnectionOut(
                tag: uuid,
                pid: pid,
                ppid: ppid,
                remoteAddress: remote.0,
                localAddress: local.0,
                remotePort: remote.1,
                localPort: local.1
            );
        case connection_update:
            let uuid = UUID.init(uuid:buffer.tag)
            var update : Optional<ConnectionState>
            
            switch(buffer.data.update_event) {
            case connecting:
                update = Optional(ConnectionState.connecting)
            case connected:
                update = Optional(ConnectionState.connected)
            case disconnecting:
                update = Optional(ConnectionState.disconnecting)
            case disconnected:
                update = Optional(ConnectionState.disconnected)
            case closing:
                update = Optional(ConnectionState.closing)
            case bound:
                update = Optional(ConnectionState.bound)
            default:
                update = Optional.none
            }
            
            if( update == nil) {
                return Optional.none
            }
            
            return FirewallConnectionUpdate(tag: uuid, update: update!)
            
        default:
            print("Unkown firewall type")
        }
        
        return Optional.none
    }
    
    func waitForData() -> Bool {
        let queue = UnsafeMutablePointer<IODataQueueMemory>.init(bitPattern: UInt(notificationMemory))
        
        if kIOReturnSuccess != IODataQueueWaitForAvailableData(queue!, notificationPort) {
            return false
        }
        
        return true
    }
    
    
    func enable() -> Bool {
        var output : UInt64 = 0;
        var outputCount : UInt32 = 1;
        
        if kIOReturnSuccess != IOConnectCallScalarMethod(connection, 0, nil, 0, &output, &outputCount) {
            print("unable to communicate with driver!")
            return false
        }
        
        if output == 1 {
            return true
        }
        
        return false
    }
    
    func disable() {
        var outputCount : UInt32 = 0;
        if kIOReturnSuccess != IOConnectCallScalarMethod(connection, 1, nil, 0, nil, &outputCount) {
            print("unable to communicate with driver!")
        }
    }
}
