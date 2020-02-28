//
//  KextComm.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import Logging

struct DNSHeader {
    var id : UInt16;
    var flags : UInt16;
    var questionCount : UInt16;
    var answerCount : UInt16;
    var authorityCount : UInt16;
    var additionalCount : UInt16;
}

enum DNSAnswerError: Error {
    case invalidQType
}


class KextComm {
    let logger = Logger(label: "com.zerotrust.client.KextComm")
    
    private let processManager : ProcessManager

    private var notificationPortOpen = false
    private var notificationMemory : mach_vm_address_t = 0
    private var notificationMemorySize : mach_vm_size_t = 0
    private var notificationPort : mach_port_t = 0
    
    private var isOpen = false;
    private var connection : io_connect_t = 0
    private var service : io_service_t = 0
    
    private var queue : UnsafeMutablePointer<IODataQueueMemory>? = nil;
    
    init(processManager : ProcessManager) {
        self.processManager = processManager
    }
    
    func open() -> Bool {
        if isOpen {
            return true
        }
        
        service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("com_notrust_firewall_driver"))
        
        if service == 0 {
            logger.error("unable to find service")
            return false
        }
        
        if kIOReturnSuccess != IOServiceOpen(service, mach_task_self_, 0, &connection) {
            logger.error("unable to open service")
            IOObjectRelease(service)
            service = 0
            isOpen = false
        } else {
            isOpen = true
        }
        
        logger.debug("successfully opened service")
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
            logger.error("unable to create notification port!")
            return false
        }
        
        if kIOReturnSuccess != IOConnectSetNotificationPort(connection, 0x1, notificationPort, 0x0)  {
            logger.error("unable to set notication port!")
            return false
        }
        
        
        if kIOReturnSuccess != IOConnectMapMemory(connection,
                                                  UInt32(kIODefaultMemoryType),
                                                  mach_task_self_,
                                                  &notificationMemory,
                                                  &notificationMemorySize,
                                                  IOOptionBits(kIOMapAnywhere)) {
            logger.error("unable to map memory")
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
            logger.error("Unable to unmap memory, this isn't good")
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
        
        logger.info("trying to dequeue")
        if kIOReturnSuccess != IODataQueueDequeue(queue, &buffer, &size) {
            logger.error("Unable to dequeue data")
            return Optional.none
        }
        
        
        logger.info("checking buffer type")
        switch buffer.type {
        case outbound_connection:
            logger.info("outbound connection")
            return processTCPConnection(event: &buffer, inbound: false)
        case inbound_connection:
            logger.info("inbound connection")
            return processTCPConnection(event: &buffer, inbound: true)
            
        case connection_update:
            logger.info("connection update")

            let uuid = UUID.init(uuid:buffer.tag)
            let timestamp = Double(buffer.timestamp);
            var update : Optional<ConnectionStateType>
            
            switch(buffer.data.update_event) {
            case connecting:
                update = Optional(ConnectionStateType.connecting)
            case connected:
                update = Optional(ConnectionStateType.connected)
            case disconnecting:
                update = Optional(ConnectionStateType.disconnecting)
            case disconnected:
                update = Optional(ConnectionStateType.disconnected)
            case closing:
                update = Optional(ConnectionStateType.closed)
            case bound:
                update = Optional(ConnectionStateType.bound)
            default:
                update = Optional.none
            }
            
            if( update == nil) {                
                logger.debug("have an update type we don't care about skipping")
                return Optional.none
            }
            
            return FirewallConnectionUpdate(tag: uuid, timestamp: timestamp, update: update!)
        case dns_update:
            logger.info("dns update")

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
            
            for x in 0..<header.answerCount {
                logger.info("Processing Answer count: \(x)")
                do {
                    let (updatedPointer: updatedPointer, aRecord: aRecord, cNameRecord: cNameRecord) = try processDNSAnswer(startPointer: startPointer, currentPointer: pointer)
                    pointer = updatedPointer
                    aRecord.map { aRecords.append($0) }
                    cNameRecord.map { cNameRecords.append($0) }
                } catch  {
                    logger.error("unable to process this dns update")
                    return nil
                }

            }
            
            return FirewallDNSUpdate(
                aRecords: aRecords,
                cNameRecords: cNameRecords,
                questions: questions
            )
            
        case query:
            logger.info("query")
            var message = buffer.data.query_event
            
            let tag = UUID.init(uuid: buffer.tag)
            let timestamp = Double(buffer.timestamp)
            let id = message.query_id
            
            let remote = SocketAddress(message.remote)
            let local = SocketAddress(message.local)

            let procName = withUnsafeBytes(of: &message.proc_name) { (rawPtr) -> String in
                let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
                return String(cString: ptr)
            }
            
            let process = processManager.get(pid: message.pid, ppid: message.ppid, command: procName)

            
            return FirewallQuery(
                tag: tag,
                id: id,
                timestamp: timestamp,
                remoteSocket: remote,
                localSocket:  local,
                processInfo:  process
            )
            
        default:
            logger.error("Unknown firewall type")
        }
        
        return Optional.none
    }
    
    private func processTCPConnection(event : inout firewall_event, inbound: Bool) -> Optional<TCPConnection> {
        let uuid = UUID.init(uuid: event.tag)
        let pid = event.data.tcp_connection.pid;
        let ppid = event.data.tcp_connection.ppid;
        let timestamp = Double(event.timestamp);
        
        let procName = withUnsafeBytes(of: &event.data.tcp_connection.proc_name) { (rawPtr) -> String in
            let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
            return String(cString: ptr)
        }
        
        let info = processManager.get(pid: pid, ppid: ppid,command: procName)
        let remote = SocketAddress(event.data.tcp_connection.remote)
        let local = SocketAddress(event.data.tcp_connection.local)
        
        let outcome : Outcome = {
            switch(event.data.tcp_connection.result) {
            case ALLOWED: return Outcome.allowed
            case BLOCKED: return Outcome.blocked
            case QUARANTINED: return Outcome.inspectModeBlocked
            case ISOLATED: return Outcome.denyModeBlocked
            default: return Outcome.unknown
            }
        }()
                
        return TCPConnection(
            tag: uuid,
            timestamp: timestamp,
            inbound:  inbound,
            process: info,
            remoteSocket: remote,
            localSocket: local,
            outcome: outcome
        )
    }
    
    private func processDNSAnswer(startPointer: UnsafeMutableRawPointer, currentPointer: UnsafeMutableRawPointer) throws ->  (updatedPointer: UnsafeMutableRawPointer, cNameRecord: Optional<CNameRecord>, aRecord: Optional<ARecord>)  {
        var pointer = currentPointer
        let offsetResult = grabAnswerOffsetPosition(currentPointer: pointer)

            
        // Get the QType
        let qtypeResult = grabUInt16(pointer: offsetResult.updatedPointer)
        pointer = qtypeResult.updatedPointer
        let qtype = qtypeResult.value

        if qtype != 01 && qtype != 0x5 {
            throw DNSAnswerError.invalidQType
        }
        
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
                    aRecord = ARecord(url: url, ip: ip)
                } else {
                    logger.error("We have an A record which is larger than 4 Bytes. This is weird?")
                }
            case 0x5:
                let (updatedPointer: _, url: cname)  = grabURL(startPointer: startPointer, offsetPointer: startPointer.advanced(by: Int(offsetResult.offsetPosition)))
                let (_, url) = grabURL(startPointer: startPointer, offsetPointer: pointer)
                cNameRecord = CNameRecord(url: url, cName: cname)
            default: ()
        }
            
        return (updatedPointer: pointer.advanced(by: Int(length)), cNameRecord: cNameRecord, aRecord: aRecord)
    }
    
    private func processDNSHeader(startPointer: UnsafeMutableRawPointer) -> (UnsafeMutableRawPointer, DNSHeader) {
        var header = startPointer.load(as: DNSHeader.self)
        let headerSize = MemoryLayout<DNSHeader>.size
        
        header.questionCount = header.questionCount.bigEndian
        header.answerCount = header.answerCount.bigEndian
        
        return (startPointer.advanced(by: headerSize), header)
    }
    
    private func processDNSQuestion(startPointer: UnsafeMutableRawPointer, offsetPointer: UnsafeMutableRawPointer) -> (updatedPointer: UnsafeMutableRawPointer, question: String) {
        let result = grabURL(startPointer: startPointer, offsetPointer: offsetPointer)
        let url = result.url
        var currentPointer = result.updatedPointer

        currentPointer = currentPointer.advanced(by: 2)
        currentPointer = currentPointer.advanced(by: 2)
        
        return (currentPointer, url)
    }
    
    private func grabIPv4String(currentPointer: UnsafeMutableRawPointer) -> (updatedPointer: UnsafeMutableRawPointer, ip: IPAddress) {
        var (updatedPointer: pointer, value: address) = grabUInt32(pointer: currentPointer)
        address = address.bigEndian
        return (pointer, IPAddress(UInt32NetworkByeOrder: address))
    }
    
    private func grabAnswerOffsetPosition(currentPointer: UnsafeMutableRawPointer) -> (updatedPointer: UnsafeMutableRawPointer, offsetPosition: UInt16, isCompressed: Bool) {
        var (pointer, offset) = grabUInt16(pointer: currentPointer)
        var isCompressed = false
        if( offset & 0xC000 == 0xC000 ) {
            // we have a compressed query.
            offset = UInt16(offset & (0xFFFF - 0xC000))
            logger.info("we have a compressed query")
            isCompressed.toggle()
        }

        return (pointer, offset, isCompressed)
    }
    
    private func grabURL(startPointer : UnsafeMutableRawPointer, offsetPointer: UnsafeMutableRawPointer) -> (updatedPointer: UnsafeMutableRawPointer, url: String) {
        var currentPointer = offsetPointer
        var size = currentPointer.load(as: UInt8.self).bigEndian;
        var array : [UInt8] = []
        
        while( size != 0x0 ) {
            currentPointer = currentPointer.advanced(by: 1)
            for _ in 0..<size {
                array.append(currentPointer.load(as: UInt8.self))
                currentPointer = currentPointer.advanced(by: 1)
            }
            size = currentPointer.load(as: UInt8.self).bigEndian
            array.append(UInt8.init(ascii: "."))
            
            // We're at a new jump point.
            if(size == 0xC0) {
                let (_, offset) = grabUInt16(pointer: currentPointer)
                let offsetPointer = UInt16(offset & (0xFFFF - 0xC000))
                currentPointer = startPointer.advanced(by: Int(offsetPointer))
                size = currentPointer.load(as: UInt8.self).bigEndian
                logger.info("we are going to a new jump point")
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
        return (currentPointer, url)
    }
    
    private func grabUInt16(pointer : UnsafeMutableRawPointer) -> (updatedPointer: UnsafeMutableRawPointer, value: UInt16) {
        let first8Bits = pointer.load(as: UInt8.self)
        let first = UInt16(first8Bits) << 8
        var updatedPointer = pointer.advanced(by: 1)
        
        let second8Bits = updatedPointer.load(as: UInt8.self)
        let second = UInt16(second8Bits)
        updatedPointer = updatedPointer.advanced(by: 1)
        
        return (updatedPointer, first | second)
    }
    
    private func grabUInt32(pointer: UnsafeMutableRawPointer) -> (updatedPointer: UnsafeMutableRawPointer, value: UInt32) {
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
            logger.error("unable to communicate with driver!")
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
            logger.error("unable to communicate with driver!")
        }
    }
    
    func denyMode(enable: Bool) {
        var output : UInt64 = 0
        var outputCount : UInt32 = 1
        
        let methodNum : UInt32 = {
            switch enable {
            case true:
                logger.debug("starting deny mode")
                return 4
            case false:
                logger.debug("stopping deny mode")
                return 5
            }
        }()

        if kIOReturnSuccess != IOConnectCallScalarMethod(connection, methodNum, nil, 0, &output, &outputCount) {
            logger.error("unable to communicate with driver!")
        }
    }
    
    
    func inspectMode(enable: Bool) {
        var output : UInt64 = 0
        var outputCount : UInt32 = 1
        
        let methodNum : UInt32 = {
            switch enable {
            case true:
                logger.debug("starting inspect mode")
                return 2
            case false:
                logger.debug("stopping inspect mode")
                return 3
            }
        }()

        if kIOReturnSuccess != IOConnectCallScalarMethod(connection, methodNum, nil, 0, &output, &outputCount) {
            logger.error("unable to communicate with driver!")
        }
    }
    
    func postDecision(id: UInt32, allowed: UInt32) {
        var inputs = [ UInt64(id), UInt64(allowed) ];
        
        if kIOReturnSuccess != IOConnectCallScalarMethod(connection, 6, &inputs, 2, nil, nil) {
            logger.error("unable to write to driver!")
        }
    }
        
    
}
