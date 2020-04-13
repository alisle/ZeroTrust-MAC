//
//  State.swift
//  client
//
//  Created by Alex Lisle on 6/26/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


class ConnectionState  {
    private var listenState = [UUID : SocketListen]()
    private var state = [UUID: Connection]()
    private let connectionQueue = DispatchQueue(label: "com.zerotrust.mac.connectionQueue", attributes: .concurrent)
    
    var connections :  Set<Connection> {        
        get {
            var set: Set<Connection>!
            self.connectionQueue.sync {
                //set = Set(state.values.map{ $0.clone() })
                set = Set(state.values)
            }
            return set
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
        if !connection.remoteSocket.address.localhost {
            self.connectionQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else {
                    return
                }
                self.state[connection.tag] = connection
                
                EventManager.shared.triggerEvent(event: OpenedConnectionEvent(connection: connection))
                
                EventManager.shared.triggerEvent(event: ConnectionChangedEvent(connection: connection))
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
                EventManager.shared.triggerEvent(event: ConnectionChangedEvent(connection: updated))
                
                if updated.state == .disconnected || updated.state == .disconnecting {
                    EventManager.shared.triggerEvent(event: ClosedConnectionEvent(connection: updated))
                }
            } else if let listen = self.listenState[tag] {
                if update == .disconnected || update == .disconnecting {
                    self.listenState.removeValue(forKey: tag)
                    EventManager.shared.triggerEvent(event: ListenEndedEvent(listen: listen))
                }
            }
            
            
        }
    }
    
    func listen(_ listen: SocketListen) {
        self.connectionQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            self.listenState[listen.tag!] = listen
            EventManager.shared.triggerEvent(event: ListenStartedEvent(listen: listen))
        }
    }
}
