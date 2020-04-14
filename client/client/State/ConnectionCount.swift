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
    private var currentInboundConnections: Set<UUID> = []
    private var currentListenSockets: Set<UUID> = []
    
    @Published var currentInboundCount : CGFloat = 0
    @Published var currentOutboundCount : CGFloat = 0
    @Published var currentSocketListenCount : CGFloat = 0
    
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
    
    @Published var inboundCounts : [CGFloat] = [
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
        EventManager.shared.addListener(type: .OpenedConnection, listener: self)
        EventManager.shared.addListener(type: .ClosedConnection, listener: self)
        EventManager.shared.addListener(type: .ListenStarted, listener: self)
        EventManager.shared.addListener(type: .ListenEnded, listener: self)
        self.updatePublishedValues()
    }
    
    private func updatePublishedValues() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)  { [ weak self ] in
            guard let self = self else {
                return
            }
            
            
            
            let outboundCount = CGFloat(self.currentOutboundConnections.count)
            let inboundCount  = CGFloat(self.currentInboundConnections.count)
            let listenCount = CGFloat(self.currentListenSockets.count)
            
            var shadowOutbound = self.outboundCounts.dropFirst()
            var shadowInbound = self.inboundCounts.dropLast()
            
            shadowOutbound.append(outboundCount)
            shadowInbound.append(inboundCount)
            
            self.outboundCounts = Array(shadowOutbound)
            self.inboundCounts = Array(shadowInbound)
            
            self.currentOutboundCount = outboundCount
            self.currentInboundCount = inboundCount
            self.currentSocketListenCount = listenCount
            
            self.updatePublishedValues()
        }
    }
    
    
    func eventTriggered(event: BaseEvent) {
        switch event.type {
            
        case .OpenedConnection:
            let event = event as! OpenedConnectionEvent
            logger.debug("adding new connection \(event.connection.tag)")
            switch(event.connection.direction) {
            case .inbound: self.currentInboundConnections.insert(event.connection.tag)
            case .outbound: self.currentOutboundConnections.insert(event.connection.tag)
            }
            
        case .ClosedConnection:
            let event = event as! ClosedConnectionEvent
            switch(event.connection.direction) {
            case .inbound: let _ = self.currentInboundConnections.remove(event.connection.tag)
            case .outbound: let _ = self.currentOutboundConnections.remove(event.connection.tag)
            }
            
        case .ListenStarted:
            let event = event as! ListenStartedEvent
            self.currentListenSockets.insert(event.listen.tag!)
        
        case .ListenEnded:
            let event = event as! ListenStartedEvent
            self.currentListenSockets.remove(event.listen.tag!)

        default: ()
        }
    }
 
    
}
