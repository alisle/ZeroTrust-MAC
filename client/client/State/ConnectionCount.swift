//
//  ConnectionCount.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/11/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
import Logging

class ConnectionCounts : ObservableObject, EventListener {
    private let logger = Logger(label: "com.zerotrust.client.States.ConnectionCounts")
    private var currentOutboundConnections: Set<UUID> = []
    
    @Published var currentInboundCount : CGFloat = 0
    @Published var currentOutboundCount : CGFloat = 0
    
    @Published var outboundCounts : [CGFloat] = [
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
    ]
    
    init() {
        EventManager.shared.addListener(type: .OpenedOutboundConnection, listener: self)
        EventManager.shared.addListener(type: .ClosedOutboundConnection, listener: self)
        self.updatePublishedValues()
    }
    
    private func updatePublishedValues() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)  { [ weak self ] in
            guard let self = self else {
                return
            }
            
            
            let count = CGFloat(self.currentOutboundConnections.count)
            
            var shadow = self.outboundCounts.dropFirst()
            shadow.append(count)
            
            self.logger.debug("connection count: \(count)")
            
            self.outboundCounts = Array(shadow)
            self.currentOutboundCount = count
            self.updatePublishedValues()
        }
    }
    
    
    func eventTriggered(event: BaseEvent) {
        switch event.type {
        case .OpenedOutboundConnection:
            let event = event as! OpenedOutboundConnectionEvent
            logger.debug("adding new connection \(event.connection.tag)")
            self.currentOutboundConnections.insert(event.connection.tag)
        case .ClosedOutboundConnection:
            let event = event as! ClosedOutboundConnectionEvent
            logger.debug("removing connection \(event.connection.tag) with count: \(self.currentOutboundConnections.count)")
            if let _ = self.currentOutboundConnections.remove(event.connection.tag) {
                logger.debug("successfully removed \(event.connection.id) with count: \(self.currentOutboundConnections.count)")
            }
            
        default: ()
        }
    }
 
    
}
