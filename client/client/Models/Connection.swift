//
//  Connection.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import SwiftUI

struct Connection : Identifiable {
    let direction : ConnectionDirection
    let id = UUID()
    let tag : UUID
    let startTimestamp : Date
    let endDateTimestamp : Date?
    let process : ProcessInfo
    let country : String?
    let remoteURL: String?
    let portProtocol : Protocol?
    let localSocket : SocketAddress
    let remoteSocket : SocketAddress
    let displayName : String
    let image : NSImage?
    let state : ConnectionStateType
    
    let outcome : Outcome
    
    var alive : Bool {
        get {
            return (self.state == .bound || self.state == .connecting || self.state == .connected)
        }
    }
    
    var dupeHash : Int {
        get {
            var hasher = Hasher()
            
            hasher.combine(self.direction)
            hasher.combine(self.remoteURL)
            hasher.combine(self.remoteSocket)
            hasher.combine(self.process)
            
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
         process: ProcessInfo,
         portProtocol : Protocol?,
         remoteURL: String?,
         remoteSocket : SocketAddress,
         localSocket : SocketAddress,
         displayName : String,
         country: String?) {
        
        self.outcome = outcome
        self.direction = direction
        self.startTimestamp = start
        self.tag = tag
        self.process = process
        self.remoteURL = remoteURL
        self.portProtocol = portProtocol
        self.remoteSocket = remoteSocket
        self.localSocket = localSocket
        self.displayName = displayName
        self.state = ConnectionStateType.unknown
        self.image = Connection.getImage(info: self.process)
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
                
        self.displayName = connection.displayName
        
        self.state = ConnectionStateType.unknown
        
        self.image = Connection.getImage(info: connection.process)
        
        self.endDateTimestamp = nil
        self.country = country
        self.process =  connection.process
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
        processInfo: ProcessInfo,
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
        self.displayName = displayName
        self.state = state
        self.image = Connection.getImage(info: processInfo)
        self.endDateTimestamp = end
        self.country = country
        self.process = processInfo
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
            processInfo: self.process,
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
            processInfo: self.process,
            displayName : self.displayName,
            country: self.country
        )
    }
    
    
    
    private static func getImage(info: ProcessInfo) -> Optional<NSImage> {
        if let nsimage = info.bundle?.icon {
            return nsimage
        }
        
        if let nsimage = info.appBundle?.icon {
            return nsimage
        }
        
        if let nsimage = info.parent?.bundle?.icon {
            return nsimage
        }
        
        if let nsimage = info.parent?.appBundle?.icon {
            return nsimage
        }
        
        return nil
    }
        
}

extension Connection : Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
        
    }
}

extension Connection : Equatable {
     public static func ==(lhs: Connection, rhs: Connection) -> Bool {
         return lhs.tag == rhs.tag
     }
}
