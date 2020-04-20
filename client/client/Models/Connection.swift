//
//  Connection.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import SwiftUI
import IP2Location

struct Connection : Identifiable, RecordDetails {
    let direction : ConnectionDirection
    let id = UUID()
    let tag : UUID
    let startTimestamp : Date
    let endDateTimestamp : Date?
    let process : ProcessDetails
    let location : IP2LocationRecord?
    let remoteURL: String?
    let localSocket : SocketAddress
    let remoteSocket : SocketAddress
    let state : ConnectionStateType
    let outcome : Outcome
    let alive : Bool 
    
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

    
    var duration : TimeInterval {
        let date = self.endDateTimestamp ?? Date()
        return date.timeIntervalSince(startTimestamp)
    }
    
    init(connection: TCPConnection,
         location: IP2LocationRecord?,
         remoteURL : String?,
         portProtocol : PortProtocolDetails? ) {
        
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
        self.state = ConnectionStateType.unknown
        self.endDateTimestamp = nil
        self.location = location
        self.process =  connection.process
        self.alive = self.state.alive
    }
    
    private init(
        direction : ConnectionDirection,
        outcome : Outcome,
        state: ConnectionStateType,
        tag : UUID,
        start: Date,
        updateDate: Date?,
        remoteURL: String?,
        remoteSocket : SocketAddress,
        localSocket : SocketAddress,
        processInfo: ProcessDetails,
        location: IP2LocationRecord?) {
        
        self.outcome = outcome
        self.direction = direction
        self.startTimestamp = start
        self.tag = tag
        self.remoteSocket = remoteSocket
        self.remoteURL = remoteURL
        self.localSocket = localSocket
        self.state = state
        self.endDateTimestamp = updateDate
        self.location = location
        self.process = processInfo
        self.alive = self.state.alive
    }
    
    func changeState(state: ConnectionStateType, timestamp: Date) -> Connection {
        return Connection(
            direction : self.direction,
            outcome : self.outcome,
            state: state,
            tag : self.tag,
            start: self.startTimestamp,
            updateDate: timestamp,
            remoteURL: self.remoteURL,
            remoteSocket: self.remoteSocket,
            localSocket: self.localSocket,
            processInfo: self.process,
            location: self.location
        )
    }
    
    func clone() -> Connection {
        return changeState(state: self.state, timestamp: self.endDateTimestamp ?? Date())
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
