//
//  FirewallEvent.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

enum FirewallEventType : Int {
    case outboundConnection = 0,
    inboundConnection,
    connectionUpdate,
    dnsUpdate,
    query
}


class FirewallEvent : CustomStringConvertible {
    let eventType : FirewallEventType
    let tag : Optional<UUID>
    
    init(type : FirewallEventType, tag : Optional<UUID>) {
        self.eventType = type
        self.tag = tag
    }
    
    public var description: String {
        return "EventType: \(String(describing: tag)) "
    }
}

class FirewallDNSUpdate : FirewallEvent {
    let aRecords : [ARecord]
    let cNameRecords : [CNameRecord]
    let questions : [String]
    
    init(aRecords: [ARecord], cNameRecords: [CNameRecord], questions: [String]) {
        self.aRecords = aRecords
        self.cNameRecords = cNameRecords
        self.questions = questions
        super.init(type: FirewallEventType.dnsUpdate, tag: nil)
    }
    
    public override var description: String {
        var description = super.description
        description.append("\nA Records:\n")
        self.aRecords.forEach { description.append("\t\($0.url) -> \($0.ip)\n") }
        
        description.append("\nCName Records:\n")
        self.cNameRecords.forEach { description.append("\t\($0.url) -> \($0.cName)\n") }
        
        description.append("\nQuestions:\n")
        self.questions.forEach { description.append("\t\($0)\n") }
        
        return description
    }
}


class FirewallConnectionUpdate : FirewallEvent {
    let update : ConnectionStateType
    let timestamp : Date
    
    init(tag: UUID, timestamp: TimeInterval, update: ConnectionStateType) {
        self.update = update;
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        super.init(type: FirewallEventType.connectionUpdate, tag: tag)
    }
    
    public override var description: String {
        var description = super.description
        description.append("\nUpdate Type: \(update)")
        
        return description
    }
}

class FirewallQuery : FirewallEvent {
    let id : UInt32
    let timestamp : Date
    
    let procName : String
    let pid: pid_t
    let ppid: pid_t
    
    let remoteAddress : IPAddress
    let remotePort : Int
    var remoteURL : Optional<String> = nil
    var remoteProtocol: Optional<Protocol> = nil
    
    let localAddress : IPAddress
    let localPort : Int
    var localURL: Optional<String> = nil
    var localProtocol: Optional<Protocol> = nil
    
    init(tag: UUID,
         id: UInt32,
         timestamp : TimeInterval,
         pid: pid_t,
         ppid: pid_t,
         remoteAddress : IPAddress,
         localAddress : IPAddress,
         remotePort: Int,
         localPort: Int,
         procName : String
        )  {
        self.id = id
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.pid = pid
        self.ppid = pid
        self.localPort = localPort
        self.localAddress = localAddress
        self.remotePort = remotePort
        self.remoteAddress = remoteAddress
        self.procName = procName
        super.init(type: FirewallEventType.query, tag: tag)
    }
}


class TCPConnection : FirewallEvent {
    let timestamp : Date
    let pid : pid_t
    let ppid : pid_t
    let uid : Optional<uid_t>
    let user : Optional<String>
    let remoteAddress : IPAddress
    let localAddress : IPAddress
    let localPort : Int
    let remotePort : Int
    let process : Optional<String>
    let parentProcess : Optional<String>
    let parentBundle : Optional<Bundle>
    let processBundle : Optional<Bundle>
    let parentTopLevelBundle : Optional<Bundle>
    let processTopLevelBundle: Optional<Bundle>
    let outcome : Outcome
    let inbound : Bool
    let procName : String
    var displayName : String = ""
    
    init(tag: UUID,
         timestamp : TimeInterval,
         inbound : Bool,
         pid: pid_t,
         ppid: pid_t,
         remoteAddress : IPAddress,
         localAddress : IPAddress,
         remotePort: Int,
         localPort: Int,
         procName : String,
         outcome : Outcome
        ) {
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.outcome = outcome
        self.inbound = inbound
        self.pid = pid
        self.ppid = ppid
        self.localPort = localPort
        self.localAddress = localAddress
        self.remotePort = remotePort
        self.remoteAddress = remoteAddress
        self.process = Helpers.getPidPath(pid: pid)
        self.procName = procName
        self.parentProcess = Helpers.getPidPath(pid: ppid)
        
        self.parentBundle = Helpers.getBinaryAppBundle(fullBinaryPath: parentProcess)
        self.processBundle = Helpers.getBinaryAppBundle(fullBinaryPath: process)
        
        self.parentTopLevelBundle = Helpers.getTopLevelAppBundle(fullBinaryPath: parentProcess)
        
        self.processTopLevelBundle = Helpers.getTopLevelAppBundle(fullBinaryPath: process)
        self.uid = Helpers.getUIDForPID(pid: pid)
        self.user = Helpers.getUsernameFromUID(uid: uid)
        
        super.init(type: FirewallEventType.outboundConnection, tag: tag)
        displayName = createDisplayName()        
    }
    
    private func createDisplayName()  -> String {
        if processBundle?.displayName != nil {
            return processBundle!.displayName!
        }
        
        if parentBundle?.displayName != nil {
            return parentBundle!.displayName!
        }
        
        if processTopLevelBundle?.displayName != nil {
            return processTopLevelBundle!.displayName!
        }
        
        if parentTopLevelBundle?.displayName != nil {
            return parentTopLevelBundle!.displayName!
        }
        
        if  let proc = process,
            let lastIndex = proc.lastIndex(of: "/") {
            
            let start = proc.index(after: lastIndex)
            let end = proc.endIndex
            let substring = proc[start..<end]
            
            return String(substring)
        }
        
        return procName
    }
    
    public override var description : String {
        var description = super.description
        
        description.append("\n\tPID: \(pid)")
        description.append("\n\tPPID: \(ppid)")
        description.append("\n\tApp Name: \(displayName)")
        description.append("\n\tLocal Address: \(localAddress)")
        description.append("\n\tLocal Port: \(localPort)")
        
        if(self.uid != nil) {
            description.append("\n\tUID: \(self.uid!)")
        }
        
        if(self.user != nil) {
            description.append("\n\tUsername: \(self.user!)")
        }
        
        if(self.process != nil) {
            description.append("\n\tLocal Process: \(self.process!)")
        }
        
        if self.parentProcess != nil {
            description.append("\n\tLocal Parent Process: \(self.parentProcess!)")
        }
        
        if self.processBundle != nil {
            description.append("\n\tLocal Bundle Name: \(self.processBundle!.displayName ?? "null" )")
        }
        
        if self.parentBundle != nil {
            description.append("\n\tLocal Parent Bundle Name: \(self.parentBundle!.displayName!)")
        }
        
        if self.processTopLevelBundle != nil {
            description.append("\n\tLocal Top Level Bundle Name: \(self.processTopLevelBundle!.displayName ?? "null" )")
        }
        
        if self.parentTopLevelBundle != nil {
            description.append("\n\tLocal Top Level Parent Bundle Name: \(self.parentTopLevelBundle!.displayName ?? "null")")
        }
        
        
        description.append("\n\tRemote Address: \(remoteAddress)")
        description.append("\n\tRemote port: \(remotePort)\n")
        
        return description
    }
}
