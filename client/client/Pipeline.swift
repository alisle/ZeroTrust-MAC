//
//  Pipeline.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 2/26/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
import IP2Location
import Logging


class Pipeline {
    let logger = Logger(label: "com.zerotrust.client.Pipeline")

    private let decisionEngine : DecisionEngine
    private let connectionState : ConnectionState
    private let dnsCache : DNSCache
    private let protocolCache : ProtocolCache
    private let ipdb : IP2DBLocate?
    private let kextComm : KextComm

    init(decisionEngine : DecisionEngine,
         connectionState: ConnectionState,
         dnsCache: DNSCache,
         protocolCache: ProtocolCache,
         ipdb : IP2DBLocate?,
         kextComm : KextComm
         ) {
        
        self.dnsCache = dnsCache
        self.protocolCache = protocolCache
        self.decisionEngine = decisionEngine
        self.connectionState = connectionState
        self.ipdb = ipdb
        self.kextComm = kextComm
    }
    
    public func process(event: FirewallEvent) {
        logger.debug("processing \(event.eventType)")
        
        switch(event.eventType) {
        case FirewallEventType.outboundConnection:
            let firewallEvent = event as! TCPConnection
            self.process(connection: firewallEvent)

        case FirewallEventType.connectionUpdate:
            let update = event as! FirewallConnectionUpdate
            self.process(update: update)
            
        case FirewallEventType.dnsUpdate:
            let update = event as! FirewallDNSUpdate
            self.process(dnsUpdate: update)
            
        case FirewallEventType.query:
            let query = event as! FirewallQuery
            self.process(query: query)
                                 
        default: ()
        }
    }
    
    func process(connection: TCPConnection) {
        let remoteURL = dnsCache.get(connection.remoteSocket.address)
        let remoteProtocol = protocolCache.get(connection.remoteSocket.port)
        let location = self.ipdb?.find(connection.remoteSocket.address.representation)
        
        let connection = Connection(
            connection: connection,
            location: location,
            remoteURL: remoteURL,
            portProtocol: remoteProtocol)
        
        connectionState.new(connection: connection)
    }
    
    func process(update: FirewallConnectionUpdate) {
        connectionState.update(tag: update.tag!, timestamp: update.timestamp, update: update.update)
    }
    
    func process(dnsUpdate: FirewallDNSUpdate) {
        dnsUpdate.aRecords.forEach { dnsCache.update(url: $0.url, ip: $0.ip) }
        dnsUpdate.cNameRecords.forEach { dnsCache.update(url: $0.url, cName: $0.cName)}
        dnsUpdate.questions.forEach{ dnsCache.update(question: $0) }
    }
    
    func process(query: FirewallQuery) {
        let remoteURL = dnsCache.get(query.remoteSocket.address)
        let remoteProtocol = protocolCache.get(query.remoteSocket.port)
        
        let localURL = dnsCache.get(query.localSocket.address)
        let localProtocol = protocolCache.get(query.localSocket.port)
        
        
        
        query.remoteURL = remoteURL
        query.remoteProtocol = remoteProtocol
        
        query.localURL = localURL
        query.localProtocol = localProtocol
        
                                                
        let decision = decisionEngine.decide(query)
        kextComm.postDecision(id: query.id, allowed: decision.toInt())
    }
}
