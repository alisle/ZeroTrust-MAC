//
//  Connection.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import SwiftUI

struct Connection : Hashable, Identifiable {
    let direction : ConnectionDirection
    
    let id = UUID()
    
    
    let tag : UUID
    let startTimestamp : Date
    let endDateTimestamp : Optional<Date>
    
    let pid : pid_t
    let ppid : pid_t
    
    let uid : Optional<uid_t>
    let user : Optional<String>
    
    let country : Optional<String>
    
    let remoteURL: Optional<String>
    let portProtocol : Optional<Protocol>

    let localSocket : SocketAddress
    let remoteSocket : SocketAddress
        
    let process : Optional<String>
    let parentProcess : Optional<String>
    
    let processBundle : Optional<Bundle>
    let parentBundle: Optional<Bundle>
    
    let processTopLevelBundle: Optional<Bundle>
    let parentTopLevelBundle : Optional<Bundle>
    
    let displayName : String
    
    let image : Optional<NSImage>
    let state : ConnectionStateType
    
    let outcome : Outcome
    
    var alive : Bool {
        get {
            return (self.state == .bound || self.state == .connecting || self.state == .connected)
        }
    }
    
    var  dupeHash : Int {
        get {
            var hasher = Hasher()
            
            hasher.combine(self.direction)
            hasher.combine(self.remoteURL)
            hasher.combine(self.remoteSocket)
            hasher.combine(self.pid)
            
            return hasher.finalize()
        }
    }
    
    var remoteDisplayAddress : String {
        return remoteURL ?? remoteSocket.address.description
    }

    var remoteProtocol : String {
        guard let port = self.portProtocol else {
            return "\(self.remoteSocket.port)"
        }
        
        return port.name
    }
    
    var duration : TimeInterval {
        let date = self.endDateTimestamp ?? Date()
        return date.timeIntervalSince(startTimestamp)
    }
        
    init(direction : ConnectionDirection,
         outcome : Outcome,
         tag : UUID,
         start: Date,
         pid : pid_t,
         ppid : pid_t,
         uid : Optional<uid_t>,
         user : Optional<String>,
         portProtocol : Optional<Protocol>,
         remoteURL: Optional<String>,
         remoteSocket : SocketAddress,
         localSocket : SocketAddress,
         process : Optional<String>,
         parentProcess : Optional<String>,
         processBundle : Optional<Bundle>,
         parentBundle: Optional<Bundle>,
         processTopLevelBundle: Optional<Bundle>,
         parentTopLevelBundle : Optional<Bundle>,
         displayName : String,
         country: Optional<String>) {
        
        self.outcome = outcome
        self.direction = direction
        self.startTimestamp = start
        self.tag = tag
        self.pid = pid
        self.ppid = ppid
        self.uid = uid
        self.user = user
        self.remoteURL = remoteURL
        self.portProtocol = portProtocol
        self.remoteSocket = remoteSocket
        self.localSocket = localSocket
        self.process = process
        self.parentProcess = parentProcess
        self.processBundle = processBundle
        self.parentBundle = parentBundle
        self.processTopLevelBundle = processTopLevelBundle
        self.parentTopLevelBundle = parentTopLevelBundle
        self.displayName = displayName
        self.state = ConnectionStateType.unknown
        self.image = Connection.getImage(
            processBundle: processBundle,
            processTopLevelBundle: processTopLevelBundle,
            parentBundle: parentBundle,
            parentTopLevelBundle: parentTopLevelBundle)
        self.endDateTimestamp = nil
        self.country = country
    }
    
    init(connection: TCPConnection,
         country: Optional<String>,
         remoteURL : Optional<String>,
         portProtocol : Optional<Protocol> ) {
        
        self.direction = {
            switch(connection.inbound) {
            case true: return ConnectionDirection.inbound
            case false: return ConnectionDirection.outbound
            }
        }()
        
        self.outcome = connection.outcome
        self.startTimestamp = connection.timestamp
        self.tag = connection.tag!
        
        self.pid = connection.pid
        self.ppid = connection.ppid
        
        self.uid = connection.uid
        self.user = connection.user
        
        self.remoteSocket = connection.remoteSocket
        self.localSocket = connection.localSocket
        
        self.remoteURL = remoteURL
        self.portProtocol = portProtocol
        
        self.process = connection.process
        self.parentProcess = connection.parentProcess
        
        self.processBundle = connection.processBundle
        self.parentBundle = connection.parentBundle
        
        self.processTopLevelBundle = connection.processTopLevelBundle
        self.parentTopLevelBundle = connection.parentTopLevelBundle
        
        self.displayName = connection.displayName
        
        self.state = ConnectionStateType.unknown
        
        self.image = Connection.getImage(
            processBundle: connection.processBundle,
            processTopLevelBundle: connection.processTopLevelBundle,
            parentBundle: connection.parentBundle,
            parentTopLevelBundle: connection.parentTopLevelBundle)
        
        self.endDateTimestamp = nil
        self.country = country        
    }
    
    private init(
        direction : ConnectionDirection,
        outcome : Outcome,
        state: ConnectionStateType,
        tag : UUID,
        start: Date,
        end: Optional<Date>,
        pid : pid_t,
        ppid : pid_t,
        uid : Optional<uid_t>,
        user : Optional<String>,
        portProtocol : Optional<Protocol>,
        remoteURL: Optional<String>,
        remoteSocket : SocketAddress,
        localSocket : SocketAddress,
        process : Optional<String>,
        parentProcess : Optional<String>,
        processBundle : Optional<Bundle>,
        parentBundle: Optional<Bundle>,
        processTopLevelBundle: Optional<Bundle>,
        parentTopLevelBundle : Optional<Bundle>,
        displayName : String,
        country: Optional<String>) {
        self.outcome = outcome
        self.direction = direction
        self.startTimestamp = start
        self.tag = tag
        self.pid = pid
        self.ppid = ppid
        self.uid = uid
        self.user = user
        self.remoteSocket = remoteSocket
        self.remoteURL = remoteURL
        self.portProtocol = portProtocol
        self.localSocket = localSocket
        self.process = process
        self.parentProcess = parentProcess
        self.processBundle = processBundle
        self.parentBundle = parentBundle
        self.processTopLevelBundle = processTopLevelBundle
        self.parentTopLevelBundle = parentTopLevelBundle
        self.displayName = displayName
        self.state = state
        self.image = Connection.getImage(
            processBundle: processBundle,
            processTopLevelBundle: processTopLevelBundle,
            parentBundle: parentBundle,
            parentTopLevelBundle: parentTopLevelBundle)
        self.endDateTimestamp = end
        self.country = country
    }
    
    func clone() -> Connection {
        return Connection(
            direction : self.direction,
            outcome : self.outcome,
            state: self.state,
            tag : self.tag,
            start: self.startTimestamp,
            end: self.endDateTimestamp,
            pid : self.pid,
            ppid : self.ppid,
            uid : self.uid,
            user : self.user,
            portProtocol : self.portProtocol,
            remoteURL: self.remoteURL,
            remoteSocket: self.remoteSocket,
            localSocket: self.localSocket,
            process : self.process,
            parentProcess : self.parentProcess,
            processBundle : self.processBundle,
            parentBundle: self.parentBundle,
            processTopLevelBundle: self.processTopLevelBundle,
            parentTopLevelBundle : self.parentTopLevelBundle,
            displayName : self.displayName,
            country: self.country
            )
    }
    
    func changeState(state: ConnectionStateType, timestamp: Date) -> Connection {
        return Connection(
            direction : self.direction,
            outcome : self.outcome,
            state: state,
            tag : self.tag,
            start: self.startTimestamp,
            end: timestamp,
            pid : self.pid,
            ppid : self.ppid,
            uid : self.uid,
            user : self.user,
            portProtocol : self.portProtocol,
            remoteURL: self.remoteURL,
            remoteSocket: self.remoteSocket,
            localSocket: self.localSocket,
            process : self.process,
            parentProcess : self.parentProcess,
            processBundle : self.processBundle,
            parentBundle: self.parentBundle,
            processTopLevelBundle: self.processTopLevelBundle,
            parentTopLevelBundle : self.parentTopLevelBundle,
            displayName : self.displayName,
            country: self.country
        )
    }
    
    
    
    private static func getImage(
        processBundle : Optional<Bundle>,
        processTopLevelBundle: Optional<Bundle>,
        parentBundle: Optional<Bundle>,
        parentTopLevelBundle: Optional<Bundle>
        ) -> Optional<NSImage> {
        if let nsimage = processBundle?.icon {
            return nsimage
        }
        
        if let nsimage = processTopLevelBundle?.icon {
            return nsimage
        }
        
        if let nsimage = parentBundle?.icon {
            return nsimage
        }
        
        if let nsimage = parentTopLevelBundle?.icon {
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
