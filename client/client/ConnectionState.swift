//
//  State.swift
//  client
//
//  Created by Alex Lisle on 6/26/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


class ConnectionState  {
    private var state = [UUID: Connection]()
    private let connectionQueue = DispatchQueue(label: "com.zerotrust.mac.connectionQueue", attributes: .concurrent)
    private var listeners : [ConnectionStateListener] = []
    
    init() {
        trim()
    }
    
    var connections :  Set<Connection> {        
        get {
            var set: Set<Connection>!
            self.connectionQueue.sync {
                set = Set(state.values.map{ $0.clone() })
            }
            return set
        }
    }

    func addListener(listener : ConnectionStateListener) {
        self.connectionQueue.sync { [weak self] in
            guard let self = self else {
                return
            }
            
            self.listeners.append(listener)
        }
    }
        
        
    func trim() {
        self.connectionQueue.asyncAfter(deadline: .now() + 60, flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.state = self.state.filter { !(($1.state == .disconnected || $1.state == .disconnecting) && $1.endDateTimestamp!.olderThan(minutes: 60)) }
            self.trim()
        }
    }
    
    func new(connection: Connection) {
        if connection.remoteAddress != "127.0.0.1" {
            self.connectionQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.state[connection.tag] = connection
                self.listeners.forEach{ $0.connectionChanged( connection.clone() )}
            }
        }
    }
    
    func update(tag: UUID, timestamp : Date, update: ConnectionStateType) {
        self.connectionQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            if let conn = self.state[tag] {
                let updated = conn.changeState(state: update, timestamp: timestamp)
                self.state[tag] = updated
                self.listeners.forEach { $0.connectionChanged( updated ) }
            }
        }
        
    }
    
    func dump() {
        self.connectionQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }
            
            for pair  in self.state {
                let value = pair.value
                print("\(value.displayName)->\(value.remoteDisplayAddress):\(value.remotePort) -- \(value.state) -- DupeHash: \(value.dupeHash)")
            }
        }
    }
    
    
}
