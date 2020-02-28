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
    
    let processInfo : ProcessInfo
    let remoteSocket : SocketAddress
    let localSocket : SocketAddress
    
    var remoteURL : Optional<String> = nil
    var remoteProtocol: Optional<Protocol> = nil
    
    var localURL: Optional<String> = nil
    var localProtocol: Optional<Protocol> = nil
    
    init(tag: UUID,
         id: UInt32,
         timestamp : TimeInterval,
         remoteSocket : SocketAddress,
         localSocket : SocketAddress,
         processInfo : ProcessInfo
        )  {
        self.id = id
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.localSocket = localSocket
        self.remoteSocket = remoteSocket
        self.processInfo = processInfo
        super.init(type: FirewallEventType.query, tag: tag)
    }
}


class TCPConnection : FirewallEvent {
    let timestamp : Date
    let remoteSocket : SocketAddress
    let localSocket : SocketAddress
    let outcome : Outcome
    let inbound : Bool
    let process : ProcessInfo
    
    var displayName : String = ""
    
    init(tag: UUID,
         timestamp : TimeInterval,
         inbound : Bool,
         process: ProcessInfo,
         remoteSocket : SocketAddress,
         localSocket : SocketAddress,
         outcome : Outcome
        ) {
        
        self.process = process
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.outcome = outcome
        self.inbound = inbound
        self.localSocket = localSocket
        self.remoteSocket = remoteSocket
        
        super.init(type: FirewallEventType.outboundConnection, tag: tag)
        displayName = createDisplayName()        
    }
    
    private func createDisplayName()  -> String {
        if let name = process.bundle?.displayName  {
            return name
        }
        
        if let name = process.parent?.bundle?.displayName {
            return name
        }
        
        if let name = process.appBundle?.displayName  {
            return name
        }
        
        if let name = process.parent?.appBundle?.displayName {
            return name
        }
        
        if let name = process.command {
            return name
        }
        
        return "Unknown"
    }
    
    public override var description : String {
        var description = super.description
        
        description.append("\n\tApp Name: \(displayName)")
        description.append("\n\tLocal Socket: \(localSocket)")
        description.append("\n\tRemote Socket: \(remoteSocket)")
        description.append("\n\t\(process.description)")
        
        return description
    }
}
