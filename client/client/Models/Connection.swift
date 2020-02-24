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
    let endDateTimestamp : Date?
    
    let processInfo : ProcessInfo
        
    let country : String?
    
    let remoteURL: String?
    let portProtocol : Protocol?

    let localSocket : SocketAddress
    let remoteSocket : SocketAddress
        
    let process : String?
    let parentProcess : String?
    
    let processBundle : Bundle?
    let parentBundle: Bundle?
    
    let processTopLevelBundle: Bundle?
    let parentTopLevelBundle : Bundle?
    
    let displayName : String
    
    let image : NSImage?
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
            hasher.combine(self.processInfo)
            
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
         processInfo: ProcessInfo,
         portProtocol : Protocol?,
         remoteURL: String?,
         remoteSocket : SocketAddress,
         localSocket : SocketAddress,
         process : String?,
         parentProcess : String?,
         processBundle : Bundle?,
         parentBundle: Bundle?,
         processTopLevelBundle: Bundle?,
         parentTopLevelBundle : Bundle?,
         displayName : String,
         country: String?) {
        
        self.outcome = outcome
        self.direction = direction
        self.startTimestamp = start
        self.tag = tag
        self.processInfo = processInfo
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
         country: String?,
         remoteURL : String?,
         portProtocol : Protocol? ) {
        
        self.direction = {
            switch(connection.inbound) {
            case true: return ConnectionDirection.inbound
            case false: return ConnectionDirection.outbound
            }
        }()
        
        self.outcome = connection.outcome
        self.startTimestamp = connection.timestamp
        self.tag = connection.tag!
                
        self.remoteSocket = connection.remoteSocket
        self.localSocket = connection.localSocket
        
        self.remoteURL = remoteURL
        self.portProtocol = portProtocol
        
        self.process = connection.process.command
        self.parentProcess = connection.process.parent?.command
        
        self.processBundle = connection.process.bundle
        self.parentBundle = connection.process.parent?.bundle
        
        self.processTopLevelBundle = connection.process.appBundle
        self.parentTopLevelBundle = connection.process.parent?.appBundle
        
        self.displayName = connection.displayName
        
        self.state = ConnectionStateType.unknown
        
        self.image = Connection.getImage(
            processBundle: connection.process.bundle,
            processTopLevelBundle: connection.process.appBundle,
            parentBundle: connection.process.parent?.bundle,
            parentTopLevelBundle: connection.process.parent?.appBundle)
        
        self.endDateTimestamp = nil
        self.country = country
        self.processInfo =  connection.process
    }
    
    private init(
        direction : ConnectionDirection,
        outcome : Outcome,
        state: ConnectionStateType,
        tag : UUID,
        start: Date,
        end: Date?,
        portProtocol : Protocol?,
        remoteURL: String?,
        remoteSocket : SocketAddress,
        localSocket : SocketAddress,
        process : String?,
        processInfo: ProcessInfo,
        parentProcess : String?,
        processBundle : Bundle?,
        parentBundle: Bundle?,
        processTopLevelBundle: Bundle?,
        parentTopLevelBundle : Bundle?,
        displayName : String,
        country: String?) {
        
        self.outcome = outcome
        self.direction = direction
        self.startTimestamp = start
        self.tag = tag
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
        self.processInfo = processInfo
    }
    
    func clone() -> Connection {
        return Connection(
            direction : self.direction,
            outcome : self.outcome,
            state: self.state,
            tag : self.tag,
            start: self.startTimestamp,
            end: self.endDateTimestamp,
            portProtocol : self.portProtocol,
            remoteURL: self.remoteURL,
            remoteSocket: self.remoteSocket,
            localSocket: self.localSocket,
            process : self.process,
            processInfo:  self.processInfo,
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
            portProtocol : self.portProtocol,
            remoteURL: self.remoteURL,
            remoteSocket: self.remoteSocket,
            localSocket: self.localSocket,
            process : self.process,
            processInfo: self.processInfo,
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
