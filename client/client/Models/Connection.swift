//
//  Connection.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import SwiftUI




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
    
    let startTimestamp : Date
    var endDateTimestamp : Optional<Date> = nil
    
    let pid : pid_t
    let ppid : pid_t
    
    let uid : Optional<uid_t>
    let user : Optional<String>
    
    let remoteAddress : String
    let remoteURL: Optional<String>
    let portProtocol : Optional<Protocol>
    
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
    
    var image : Optional<NSImage> = nil
    var state : ConnectionState = ConnectionState.unknown
    
    var remoteDisplayAddress : String {
        return remoteURL ?? remoteAddress
    }

    var remoteProtocol : String {
        guard let port = self.portProtocol else {
            return "\(self.remotePort)"
        }
        
        return port.name
    }
    
    
    
    init(tag : UUID,
         start: Date,
         pid : pid_t,
         ppid : pid_t,
         uid : Optional<uid_t>,
         user : Optional<String>,
         remoteAddress : String,
         remoteURL: Optional<String>,
         portProtocol : Optional<Protocol>,
         localAddress : String,
         localPort : Int,
         remotePort : Int,
         process : Optional<String>,
         parentProcess : Optional<String>,
         processBundle : Optional<Bundle>,
         parentBundle: Optional<Bundle>,
         processTopLevelBundle: Optional<Bundle>,
         parentTopLevelBundle : Optional<Bundle>,
         displayName : String) {

        self.direction = ConnectionDirection.Outbound
        self.startTimestamp = start
        self.tag = tag
        self.pid = pid
        self.ppid = ppid
        self.uid = uid
        self.user = user
        self.remoteAddress = remoteAddress
        self.remoteURL = remoteURL
        self.portProtocol = portProtocol
        self.localAddress = localAddress
        self.localPort = localPort
        self.remotePort = remotePort
        self.process = process
        self.parentProcess = parentProcess
        self.processBundle = processBundle
        self.parentBundle = parentBundle
        self.processTopLevelBundle = processTopLevelBundle
        self.parentTopLevelBundle = parentTopLevelBundle
        self.displayName = displayName
    }
    
    init(connectionOut: FirewallConnectionOut,
         remoteURL : Optional<String>,
         portProtocol : Optional<Protocol> ) {
        self.direction = ConnectionDirection.Outbound
        self.startTimestamp = connectionOut.timestamp
        self.tag = connectionOut.tag!
        
        self.pid = connectionOut.pid
        self.ppid = connectionOut.ppid
        
        self.uid = connectionOut.uid
        self.user = connectionOut.user
        
        self.remoteAddress = connectionOut.remoteAddress
        self.remoteURL = remoteURL
        self.portProtocol = portProtocol
        
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
        
        self.image = getImage()
    }
    
    func getImage() -> Optional<NSImage> {
        if let nsimage = self.processBundle?.icon {
            return nsimage
        }
        
        if let nsimage = self.processTopLevelBundle?.icon {
            return nsimage
        }
        
        if let nsimage = self.parentBundle?.icon {
            return nsimage
        }
        
        if let nsimage = self.parentTopLevelBundle?.icon {
            return nsimage
        }
        
        return nil
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
    }
    
}

func ==(lhs: Connection, rhs: Connection) -> Bool {
    return lhs.tag == rhs.tag
}
