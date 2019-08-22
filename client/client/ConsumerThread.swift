//
//  ConsumerThread.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import SwiftUI


class ConsumerThread : Thread {
    private let state = ConnectionState()
    private let dnsCache = DNSCache()
    private let protocolCache = ProtocolCache()
    
    public var connections : [ViewLength : [Connection]] {
        var sets = [ViewLength : [Connection]]()
        
        ViewLength.allCases.forEach {
            sets[$0] = state.connections(filter: $0)
        }
        
        return sets
    }
    
    private var isOpen = false
    private var comm = KextComm()
    
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
        
        comm.destroyNotificationPort()
        comm.disable()
        comm.close()
        
        isOpen.toggle()
    }
    
    override func main() {
        while isOpen {
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
                let firewallEvent = event as! FirewallConnectionOut
                let remoteURL = dnsCache.get(ip: firewallEvent.remoteAddress)
                let remoteProtocol = protocolCache.get(port: firewallEvent.remotePort)
                
                let connection = Connection(
                    connectionOut: event as! FirewallConnectionOut,
                    remoteURL: remoteURL,
                    portProtocol: remoteProtocol)
                
                state.new(connection: connection)
                
            case FirewallEventType.connectionUpdate:
                let update = event as! FirewallConnectionUpdate
                state.update(tag: update.tag!, timestamp: update.timestamp, update: update.update)
            case FirewallEventType.dnsUpdate:
                let update = event as! FirewallDNSUpdate
                update.aRecords.forEach { dnsCache.update(url: $0.url, ip: $0.ip) }
                update.cNameRecords.forEach { dnsCache.update(url: $0.url, cName: $0.cName)}
                update.questions.forEach{ dnsCache.update(question: $0) }
            default:
                continue
            }
        }
    }
}
