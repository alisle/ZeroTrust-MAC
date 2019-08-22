//
//  State.swift
//  client
//
//  Created by Alex Lisle on 6/26/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


class ConnectionState {
    private var state = [UUID: Connection]()
    private let lock =  NSLock()

    func connections(filter : ViewLength) -> [Connection] {
        let filtered = state.filter {
            if $1.state != .disconnected {
                return true
            } else {
                if !$1.endDateTimestamp!.olderThan(minutes: filter.length) {
                    return true
                }
            }
            
            return false
        }
  
        return Array(filtered.values).sorted(by: {
            switch $0.startTimestamp.compare($1.startTimestamp) {
            case .orderedAscending: return false
            case .orderedDescending: return true
            case .orderedSame:
                switch $0.remoteDisplayAddress.compare($1.remoteDisplayAddress) {
                case .orderedAscending : return true
                case .orderedDescending : return false
                case .orderedSame:
                    return $0.id.hashValue > $1.id.hashValue
                }
            }
        })
    }
    
    func trim() {
        lock.lock()
            state = state.filter {
                if $1.state == .disconnected, $1.endDateTimestamp!.olderThan(minutes: ViewLength.max()) {
                        return false
                }
                
                return true
            }
        lock.unlock()
    }
    
    func new(connection: Connection) {
        if connection.remoteAddress != "127.0.0.1" {
            lock.lock()
                state[connection.tag] = connection
            lock.unlock()
        }
    }
    
    func update(tag: UUID, timestamp : Date, update: ConnectionStateType) {
        lock.lock()
        state[tag]?.state = update
        if update == ConnectionStateType.disconnected {
            state[tag]?.endDateTimestamp = timestamp
        }
        lock.unlock()
        dump()
    }
    
    func dump() {
        lock.lock()
        for pair  in state {
            let value = pair.value
            print("\(value.displayName)->\(value.remoteDisplayAddress):\(value.remotePort) -- \(value.state)")
        }
        lock.unlock()
    }
    
    
}
