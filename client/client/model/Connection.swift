//
//  Connection.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import SwiftUI


enum ConnectionState: Int {
    case connecting = 1,
    connected,
    disconnecting,
    disconnected,
    closing,
    bound,
    unknown
    
    var description : String {
        switch self {
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .disconnecting: return "Disconnecting"
        case .disconnected: return "Disconnected"
        case .closing: return "Closing"
        case .bound: return "Bound"
        case .unknown: return "Unknown"
        }
    }
}

enum ConnectionDirection : Int {
    case Inbound = 1,
    Outbound
}

struct Connection : Hashable, Identifiable {
    let direction : ConnectionDirection
    
    let tag : UUID
    
    var id : UUID {
        get { self.tag }
    }
    
    let pid : pid_t
    let ppid : pid_t
    
    let uid : Optional<uid_t>
    let user : Optional<String>
    
    let remoteAddress : String
    let remoteURL: Optional<String>
    
    let localAddress : String
    
    let localPort : Int
    let remotePort : Int
    
    let process : Optional<String>
    let parentProcess : Optional<String>
    
    let processBundle : Optional<Bundle>
    let parentBundle: Optional<Bundle>
    
    let processTopLevelBundle: Optional<Bundle>
    let parentTopLevelBundle : Optional<Bundle>
    
    let displayName : String
    var state : ConnectionState = ConnectionState.unknown
    
    var remoteDisplayAddress : String {
        return remoteURL ?? remoteAddress
    }

    init(connectionOut: FirewallConnectionOut, remoteURL : Optional<String>) {
        self.direction = ConnectionDirection.Outbound
        
        self.tag = connectionOut.tag!
        
        self.pid = connectionOut.pid
        self.ppid = connectionOut.ppid
        
        self.uid = connectionOut.uid
        self.user = connectionOut.user
        
        self.remoteAddress = connectionOut.remoteAddress
        self.remoteURL = remoteURL
        
        self.localAddress = connectionOut.localAddress
        
        self.localPort = connectionOut.localPort
        self.remotePort = connectionOut.remotePort
        
        self.process = connectionOut.process
        self.parentProcess = connectionOut.parentProcess
        
        self.processBundle = connectionOut.processBundle
        self.parentBundle = connectionOut.parentBundle
        
        self.processTopLevelBundle = connectionOut.processTopLevelBundle
        self.parentTopLevelBundle = connectionOut.parentTopLevelBundle
        
        self.displayName = connectionOut.displayName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
    }
    
}

func ==(lhs: Connection, rhs: Connection) -> Bool {
    return lhs.tag == rhs.tag
}
