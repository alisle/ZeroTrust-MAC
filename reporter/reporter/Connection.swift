//
//  Connection.swift
//  reporter
//
//  Created by Alex Lisle on 6/18/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


enum ConnectionState: Int {
    case connecting = 1,
    connected,
    disconnecting,
    disconnected,
    closing,
    bound,
    unknown
}

enum ConnectionDirection : Int {
    case Inbound = 1,
    Outbound
}

class Connection : Hashable {
    let direction : ConnectionDirection
    
    let tag : UUID
    
    let pid : pid_t
    let ppid : pid_t
    
    let uid : Optional<uid_t>
    let user : Optional<String>
    
    let remoteAddress : String
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
    
    
    init(connectionOut: FirewallConnectionOut) {
        self.direction = ConnectionDirection.Outbound
        
        self.tag = connectionOut.tag
        
        self.pid = connectionOut.pid
        self.ppid = connectionOut.ppid
        
        self.uid = connectionOut.uid
        self.user = connectionOut.user
        
        self.remoteAddress = connectionOut.remoteAddress
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
