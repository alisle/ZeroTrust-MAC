//
//  ConsumerThread.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import SwiftUI
import IP2Location
import Logging

class Consumer : EventListener {
    let logger = Logger(label: "com.zerotrust.client.Consumer")

    private let pipeline : Pipeline
    private let comm : KextComm

    private var isOpen = false
    
    
    init( pipeline: Pipeline, kextComm : KextComm) {
        self.pipeline = pipeline
        self.comm = kextComm
                        
        registerEventHandlers()
    }
    
    private func registerEventHandlers() {
        EventManager.shared.addListener(type: .FirewallEnabled, listener: self)
        EventManager.shared.addListener(type: .FirewallDisabled, listener: self)
        
        EventManager.shared.addListener(type: .StartInspectMode, listener: self)
        EventManager.shared.addListener(type: .StopInspectMode, listener: self)
        
        EventManager.shared.addListener(type: .StartDenyMode, listener: self)
        EventManager.shared.addListener(type: .StopDenyMode, listener: self)
    }
    
    func eventTriggered(event: BaseEvent) {        
        switch event.type {
        case .FirewallEnabled: let _ = self.open()
        case .FirewallDisabled: self.close()
        default: ()
        }
    }
    
    
    private func open() -> Bool {
        if isOpen {
            return true
        }
        
        if !comm.open() {
            return false
        }
        
        if !comm.enable() {
            return false
        }
        
        if !comm.createNotificationPort() {
            return false
        }
        
        isOpen.toggle()
        
        return true
    }
    
    private func close() {
        if !isOpen {
            return
        }
        
        isOpen.toggle()

        comm.destroyNotificationPort()
        comm.disable()
        comm.close()
        
    }
    
    func loop() {
        while true {
            while isOpen {
                logger.debug("checking for data")
                if !comm.hasData() {
                    logger.debug("waiting on data")

                    if !comm.waitForData() {
                        logger.error("wait for data failed.")
                        return
                    }
                }

                logger.debug("dequeuing data")
                guard let event = comm.dequeue() else {
                    logger.debug("event is null skipping")
                    continue
                }
                
                pipeline.process(event: event)
                
                logger.debug("finished processing event")
            }
            
            logger.debug("sleeping because we aren't open")
            sleep(10)
        }
    }
}
