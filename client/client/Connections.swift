//
//  Connections.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class Connections : BindableObject {
    var willChange = PassthroughSubject<Void, Never>()
    var establishedConnections = [Connection]() { didSet { willChange.send() } }
    let consumerThread : ConsumerThread = ConsumerThread()

    init() {
        let _ = consumerThread.open()
        consumerThread.start()
        
        update()
    }
    
    func update() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.establishedConnections = self.consumerThread.connections
            self.update()
        }
    }
    
}
