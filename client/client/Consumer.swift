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

class Consumer : ServiceStateListener {
    let logger = Logger(label: "com.zerotrust.client.Consumer")

    private let decisionEngine : DecisionEngine
    private let connectionState : ConnectionState
    private let dnsCache = DNSCache()
    private let protocolCache = ProtocolCache()
    
    private var isOpen = false
    private var comm = KextComm()
    
    private let ipdb : Optional<IP2DBLocate>
    
    init(decisionEngine : DecisionEngine, connectionState: ConnectionState) {
        self.decisionEngine = decisionEngine
        self.connectionState = connectionState
        if let filepath = Bundle.main.url(forResource: "IP2LOCATION-LITE-DB11", withExtension: "BIN") {
            do {
                logger.info("loading IP2Location DB")
                self.ipdb = try IP2DBLocate(file: filepath)
            } catch  {
                logger.error("Unable to load IP2Location database")
                self.ipdb = nil
            }
        } else {
            self.ipdb = nil
        }
        
    }
    
    
    func serviceStateChanged(type: ServiceStateType, serviceEnabled: Bool) {
        switch type {
        case .enabled:
            if serviceEnabled {
               let _ = self.open()
            } else {
                self.close()
            }
        case .denyMode: comm.denyMode(enable: serviceEnabled)
        case .inspectMode: comm.inspectMode(enable: serviceEnabled)
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

                logger.info("dequeuing data")
                guard let event = comm.dequeue() else {
                    logger.debug("event is null skipping")
                    continue
                }
                
                logger.info("processing event")
                switch(event.eventType) {
                case FirewallEventType.outboundConnection:
                    let firewallEvent = event as! TCPConnection
                    let remoteURL = dnsCache.get(firewallEvent.remoteAddress)
                    let remoteProtocol = protocolCache.get(firewallEvent.remotePort)
                    let tcpConnection = event as! TCPConnection
                    let country = self.ipdb?.find(tcpConnection.remoteAddress.representation)?.iso
                    
                    let connection = Connection(
                        connection: tcpConnection,
                        country: country,
                        remoteURL: remoteURL,
                        portProtocol: remoteProtocol)
                    
                    connectionState.new(connection: connection)

                case FirewallEventType.connectionUpdate:
                    let update = event as! FirewallConnectionUpdate
                    connectionState.update(tag: update.tag!, timestamp: update.timestamp, update: update.update)
                    
                case FirewallEventType.dnsUpdate:
                    let update = event as! FirewallDNSUpdate
                    update.aRecords.forEach { dnsCache.update(url: $0.url, ip: $0.ip) }
                    update.cNameRecords.forEach { dnsCache.update(url: $0.url, cName: $0.cName)}
                    update.questions.forEach{ dnsCache.update(question: $0) }
                    
                case FirewallEventType.query:
                    let query = event as! FirewallQuery
                                        
                    let remoteURL = dnsCache.get(query.remoteAddress)
                    let remoteProtocol = protocolCache.get(query.remotePort)
                    
                    let localURL = dnsCache.get(query.localAddress)
                    let localProtocol = protocolCache.get(query.localPort)
                    
                    query.remoteURL = remoteURL
                    query.remoteProtocol = remoteProtocol
                    
                    query.localURL = localURL
                    query.localProtocol = localProtocol
                    
                                                            
                    let decision = decisionEngine.decide(query)
                    comm.postDecision(id: query.id, allowed: decision.toInt())
                    
                default:
                    continue
                }
                
                logger.info("finished processing event")
            }
            logger.debug("sleeping because we aren't open")
            sleep(10)
        }
    }
}
