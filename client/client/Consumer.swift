//
//  ConsumerThread.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import SwiftUI


class Consumer {
    private let decisionEngine : DecisionEngine
    private let state : ConnectionState
    private let dnsCache = DNSCache()
    private let protocolCache = ProtocolCache()
    
    private var isOpen = false
    private var comm = KextComm()
    
    init(decisionEngine : DecisionEngine, state: ConnectionState) {
        self.decisionEngine = decisionEngine
        self.state = state
    }
    
    
    func open() -> Bool {
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
    
    func close() {
        if !isOpen {
            return
        }
        
        isOpen.toggle()

        comm.destroyNotificationPort()
        comm.disable()
        comm.close()
        
    }
    
    func quarantine(enable: Bool) {
        comm.quarantine(enable: enable)
    }
    
    func isolate(enable: Bool) {
        comm.isolate(enable: enable)
    }
    
    func loop() {
        while true {
            while isOpen {
                print("checking for data")
                if !comm.hasData() {
                    print("waiting on data")

                    if !comm.waitForData() {
                        print("wait for data failed....")
                        return
                    }
                    
                    print("got data")
                }

                print("dequeuing data")
                guard let event = comm.dequeue() else {
                    print("event is null skipping")
                    continue
                }
                
                print("processing event")
                switch(event.eventType) {
                case FirewallEventType.outboundConnection:
                    let firewallEvent = event as! TCPConnection
                    let remoteURL = dnsCache.get(firewallEvent.remoteAddress)
                    let remoteProtocol = protocolCache.get(firewallEvent.remotePort)
                    
                    let connection = Connection(
                        connection: event as! TCPConnection,
                        remoteURL: remoteURL,
                        portProtocol: remoteProtocol)
                    
                    print("updating state")
                    state.new(connection: connection)
                    print("updated state")

                case FirewallEventType.connectionUpdate:
                    let update = event as! FirewallConnectionUpdate
                    state.update(tag: update.tag!, timestamp: update.timestamp, update: update.update)
                    
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
                
                print("finished processing event")
            }
            print("sleeping because we aren't open")
            sleep(10)
        }
    }
}
