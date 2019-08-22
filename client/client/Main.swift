//
//  EntryPoint.swift
//  client
//
//  Created by Alex Lisle on 8/12/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


class Main {
    let consumerThread : ConsumerThread = ConsumerThread()
    let currentConnections : CurrentConnections = CurrentConnections()
    
    
    func entryPoint() {
        let _ = consumerThread.open()
        consumerThread.start()
        queueUpdate()
    }
    
    private func queueUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentConnections.connections = self.consumerThread.connections
            self.queueUpdate()
        }
    }

    func getAllConnections() -> [ViewLength: [Connection]] {
        return consumerThread.connections
    }

    func getConnections(filter: ViewLength) -> [Connection] {
        return consumerThread.connections[filter]!
    }
    
    func exitPoint() {
        
    }
    
    

}
