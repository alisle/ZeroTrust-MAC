//
//  FirewallEventConsumer.swift
//  reporter
//
//  Created by Alex Lisle on 6/18/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

class FirewallEventConsumer {
    private var isOpen : Bool  = false
    private var currentConnections : Optional<CurrentConnections>
    private let comm = KernComm()
    
    init() {
        currentConnections = Optional.none
    }
    
    convenience init(state : CurrentConnections ) {
        self.init()
        self.currentConnections = state
    }
    
    func open() -> Bool {
        if isOpen {
            return true
        }
        
        if !comm.open() {
            print("Unable to open communication with driver!")
            return false
        }
        
        if !comm.enable() {
            print("Unable to enable firewall!")
            return false
        }
        
        if !comm.createNotificationPort() {
            print("Unable to create notification port")
            return false
        }
        
        isOpen = true
        return true
    }
    
    func close()  {
        if !isOpen {
            return
        }
        
        comm.destroyNotificationPort()
        comm.disable()
        comm.close()
        
        isOpen = false
    }
    
    func process()  {
        while(true) {
            if !comm.hasData() {
                if !comm.waitForData() {
                    return
                }
            }
            
            guard let event = comm.dequeue() else {
                continue
            }
            
            switch(event.eventType) {
            case FirewallEventType.outboundConnection:
                let connection = Connection(connectionOut: event as! FirewallConnectionOut)
                currentConnections?.new(connection: connection)
            case FirewallEventType.connectionUpdate:
                let update = event as! FirewallConnectionUpdate
                currentConnections?.update(tag: update.tag, update: update.update)
            default:
                continue
            }
            
        }
    }
    
}
