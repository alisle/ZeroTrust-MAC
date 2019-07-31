//
//  KextComm.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

struct DNSHeader {
    var id : UInt16;
    var flags : UInt16;
    var questionCount : UInt16;
    var answerCount : UInt16;
    var authorityCount : UInt16;
    var additionalCount : UInt16;
}

class KextComm {
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
            )
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
        case dns_update:
            var aRecords : [ARecord] = []
            var cNameRecords : [CNameRecord] = []
            var questions: [ String ] = []
            
            
            var message = buffer.data.dns_event.dns_message
            let startPointer = UnsafeMutableRawPointer(&message)
            var (pointer, header) = processDNSHeader(startPointer: startPointer)
            
            for _ in 0..<header.questionCount {
                let (updatedPointer: updatedPointer, question: question) = processDNSQuestion(startPointer: startPointer, offsetPointer: pointer)
                pointer = updatedPointer
                questions.append(question)
            }
            
            for _ in 0..<header.answerCount {
                let (updatedPointer: updatedPointer, aRecord: aRecord, cNameRecord: cNameRecord) = processDNSAnswer(startPointer: startPointer, currentPointer: pointer)
                pointer = updatedPointer
                aRecord.map { aRecords.append($0) }
                cNameRecord.map { cNameRecords.append($0) }
            }
            
            return FirewallDNSUpdate(aRecords: aRecords, cNameRecords: cNameRecords, questions: questions)
        default:
            print("Unknown firewall type")
        }
        
        return Optional.none
    }
    
    func processDNSAnswer(startPointer: UnsafeMutableRawPointer, currentPointer: UnsafeMutableRawPointer) ->  (updatedPointer: UnsafeMutableRawPointer, cNameRecord: Optional<CNameRecord>, aRecord: Optional<ARecord>) {
        var pointer = currentPointer
        let offsetResult = grabAnswerOffsetPosition(currentPointer: pointer)
        
        // Get the QType
        let qtypeResult = grabUInt16(pointer: offsetResult.updatedPointer)
        pointer = qtypeResult.updatedPointer
        let qtype = qtypeResult.value
        
        print("QType: \(qtype)")

        // Skip over the QClass and TTL.
        pointer = pointer.advanced(by: 6)

        // Grab the Length
        let lengthResult = grabUInt16(pointer: pointer)
        pointer = lengthResult.updatedPointer
        let length = lengthResult.value
        
        var cNameRecord : Optional<CNameRecord> = nil
        var aRecord : Optional<ARecord> = nil
        
        switch(qtype) {
        case 0x1:
            if length == 4 {
                let (updatedPointer: _, url: url)  = grabURL(startPointer: startPointer, offsetPointer: startPointer.advanced(by: Int(offsetResult.offsetPosition)))
                let (updatedPointer: _, ip: ip) = grabIPv4String(currentPointer: pointer)
                print("A Record: \(url) -> \(ip)")
                aRecord = ARecord(url: url, ip: ip)
            } else {
                print("We have an A record which is larger than 4 Bytes. This is weird?")
            }
        case 0x5:
            let (updatedPointer: _, url: cname)  = grabURL(startPointer: startPointer, offsetPointer: startPointer.advanced(by: Int(offsetResult.offsetPosition)))
            let (_, url) = grabURL(startPointer: startPointer, offsetPointer: pointer)
            print("CNAME Record: \(url) -> \(cname)")
            cNameRecord = CNameRecord(url: url, cName: cname)
        default: ()
        }
        
        return (updatedPointer: pointer.advanced(by: Int(length)), cNameRecord: cNameRecord, aRecord: aRecord)
    }
    
    func processDNSHeader(startPointer: UnsafeMutableRawPointer) -> (UnsafeMutableRawPointer, DNSHeader) {
        var header = startPointer.load(as: DNSHeader.self)
        let headerSize = MemoryLayout<DNSHeader>.size
        
        header.questionCount = header.questionCount.bigEndian
        header.answerCount = header.answerCount.bigEndian
        
        return (startPointer.advanced(by: headerSize), header)
    }
    
    func processDNSQuestion(startPointer: UnsafeMutableRawPointer, offsetPointer: UnsafeMutableRawPointer) -> (updatedPointer: UnsafeMutableRawPointer, question: String) {
        let result = grabURL(startPointer: startPointer, offsetPointer: offsetPointer)
        let url = result.url
        var currentPointer = result.updatedPointer

        print("got question for \(url)")
        currentPointer = currentPointer.advanced(by: 2)
        currentPointer = currentPointer.advanced(by: 2)
        
        return (currentPointer, url)
    }
    
    func grabIPv4String(currentPointer: UnsafeMutableRawPointer) -> (updatedPointer: UnsafeMutableRawPointer, ip: String) {
        var (updatedPointer: pointer, value: address) = grabUInt32(pointer: currentPointer)
        address = address.bigEndian
        let addressString = Helpers.getIPString(address: &address)
        return (pointer, addressString!)
    }
    
    func grabAnswerOffsetPosition(currentPointer: UnsafeMutableRawPointer) -> (updatedPointer: UnsafeMutableRawPointer, offsetPosition: UInt16) {
        var (pointer, offset) = grabUInt16(pointer: currentPointer)
        
        if( offset & 0xC000 == 0xC000 ) {
            // we have a compressed query.
            offset = UInt16(offset & (0xFFFF - 0xC000))
        }

        return (pointer, offset)
    }
    
    func grabURL(startPointer : UnsafeMutableRawPointer, offsetPointer: UnsafeMutableRawPointer) -> (updatedPointer: UnsafeMutableRawPointer, url: String) {
        print("extracting URL")
        var currentPointer = offsetPointer
        var size = currentPointer.load(as: UInt8.self).bigEndian;
        var array : [UInt8] = []
        
        while( size != 0x0 ) {
            currentPointer = currentPointer.advanced(by: 1)
            print("Got Section with size: \(size)")
            for _ in 0..<size {
                array.append(currentPointer.load(as: UInt8.self))
                currentPointer = currentPointer.advanced(by: 1)
            }
            size = currentPointer.load(as: UInt8.self).bigEndian
            array.append(UInt8.init(ascii: "."))
            
            // We're at a new jump point.
            if(size == 0xC0) {
                print("We are skipping to a new point")
                let (_, offset) = grabUInt16(pointer: currentPointer)
                let offsetPointer = UInt16(offset & (0xFFFF - 0xC000))
                currentPointer = startPointer.advanced(by: Int(offsetPointer))
                size = currentPointer.load(as: UInt8.self).bigEndian
            }
        }
        
        // Drop the last "."
        array = array.dropLast()
        
        // Make sure that the array is null terminated otherwise we get weird results.
        array.append(UInt8.init(0x0))
        
        // Bypass the last size.
        currentPointer = currentPointer.advanced(by: 1)
        
        // Generate the string.
        let url = String(cString: array)
        
        print("This is what we're looking at \(url)")
        return (currentPointer, url)
    }
    
    func grabUInt16(pointer : UnsafeMutableRawPointer) -> (updatedPointer: UnsafeMutableRawPointer, value: UInt16) {
        let first = UInt16(pointer.load(as: UInt8.self)) << 8
        var updatedPointer = pointer.advanced(by: 1)
        
        let second = UInt16(updatedPointer.load(as: UInt8.self))
        updatedPointer = updatedPointer.advanced(by: 1)
        
        return (updatedPointer, first | second)
    }
    
    func grabUInt32(pointer: UnsafeMutableRawPointer) -> (updatedPointer: UnsafeMutableRawPointer, value: UInt32) {
        let (firstPointer, first) = grabUInt16(pointer: pointer)
        let (secondPointer, second) = grabUInt16(pointer: firstPointer)
        let full = UInt32(first) << 16 | UInt32(second)
        return (secondPointer, full)
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
