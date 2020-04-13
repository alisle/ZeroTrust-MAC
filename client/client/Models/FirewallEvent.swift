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
    query,
    socketListener
}


enum FirewallEventQueryProtocolType : Int {
    case InboundUDPV4 = 0,
    OutboundUDPV4,
    
    InboundTCPV4,
    OutboundTCPV4,
    
    InboundUDPV6,
    OutboundUDPv6,
    
    InboundTCPV6,
    OutboundTCPV6
    

    static public func from(_ type: protocol_type) -> FirewallEventQueryProtocolType? {
        switch type {
        case inbound_udp_v4:  return InboundUDPV4
        case outbound_udp_v4: return OutboundUDPV4
        case inbound_tcp_v4:  return InboundTCPV4
        case outbound_tcp_v4: return OutboundTCPV4
        case inbound_udp_v6:  return InboundUDPV6
        case outbound_udp_v6: return OutboundUDPv6
        case inbound_tcp_v6:  return InboundTCPV6
        case outbound_tcp_v6: return OutboundTCPV6
        default: return nil
        }
    }
    
    var description : String {
        get {
            switch self {
            case .InboundUDPV4:  return "UDP:V4:\u{2190}"
            case .OutboundUDPV4: return "UDP:V4:\u{2192}"
            case .InboundTCPV4:  return "TCP:V4:\u{2190} "
            case .OutboundTCPV4: return "TCP:V4:\u{2192}"
            case .InboundUDPV6:  return "UDP:V6:\u{2190}"
            case .OutboundUDPv6: return "UDP:V6:\u{2192}"
            case .InboundTCPV6:  return "TCP:V6:\u{2190}"
            case .OutboundTCPV6: return "TCP:V6:\u{2192}"
            }
        }
    }
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
        super.init(type: .dnsUpdate, tag: nil)
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
        super.init(type: .connectionUpdate, tag: tag)
    }
    
    public override var description: String {
        var description = super.description
        description.append("\nUpdate Type: \(update)")
        
        return description
    }
}



class FirewallQuery : FirewallEvent, Identifiable {
    let id : UInt32
    let timestamp : Date
    let protocolVersion : FirewallEventQueryProtocolType
    let process : ProcessDetails
    let remoteSocket : SocketAddress
    let localSocket : SocketAddress
    
    var remoteURL : Optional<String> = nil
    var remoteProtocol: Optional<Protocol> = nil
    
    var localURL: Optional<String> = nil
    var localProtocol: Optional<Protocol> = nil
    
    init(tag: UUID,
         id: UInt32,
         timestamp : TimeInterval,
         version : FirewallEventQueryProtocolType,
         remoteSocket : SocketAddress,
         localSocket : SocketAddress,
         process : ProcessDetails
        )  {
        self.id = id
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.localSocket = localSocket
        self.remoteSocket = remoteSocket
        self.process = process
        self.protocolVersion = version
        super.init(type: .query, tag: tag)
    }
    
    override var description: String {
        return "\(self.timestamp.description): \(id):\(self.protocolVersion.description):\(self.localSocket)\u{2192}\(self.remoteSocket):\(self.process.shortDescription)"
    }

}

        
extension FirewallQuery : Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.tag)
    }
}

extension FirewallQuery : Equatable {
    public static func ==(lhs: FirewallQuery, rhs: FirewallQuery) -> Bool {
        return lhs.tag == rhs.tag
    }
}

class TCPConnection : FirewallEvent {
    let timestamp : Date
    let remoteSocket : SocketAddress
    let localSocket : SocketAddress
    let outcome : Outcome
    let inbound : Bool
    let process : ProcessDetails
    
    var displayName : String = ""
    
    init(tag: UUID,
         timestamp : TimeInterval,
         inbound : Bool,
         process: ProcessDetails,
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
        
        super.init(type: .outboundConnection, tag: tag)
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
