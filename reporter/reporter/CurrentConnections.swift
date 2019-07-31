//
//  CurrentConnections.swift
//  reporter
//
//  Created by Alex Lisle on 6/18/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

class CurrentConnections {
    private var state = [UUID: Connection]()
    private let lock = NSLock()
    
    func new(connection: Connection) {
        lock.lock()
            state[connection.tag] = connection
        lock.unlock()
    }
    
    func update(tag : UUID, update : ConnectionState ) {
        lock.lock()
            state[tag]?.state = update
            if update == ConnectionState.disconnected {
                state.removeValue(forKey: tag)
            }
        lock.unlock()
    }
    
    func dump() {
        lock.lock()
            for pair  in state {
                let value = pair.value
                print("\(value.displayName)->\(value.remoteAddress):\(value.remotePort) -- \(value.state)")
            }
        lock.unlock()
    }
    
    
}
