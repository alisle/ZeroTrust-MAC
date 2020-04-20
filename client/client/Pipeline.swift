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


class Pipeline : EventListener {
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
        
        EventManager.shared.addListener(type: .DecisionMade, listener: self)
    }
    
    public func process(event: FirewallEvent) {
        logger.debug("processing \(event.eventType)")
        
        switch(event.eventType) {
        case .outboundConnection:
            let firewallEvent = event as! TCPConnection
            self.process(connection: firewallEvent)

        case .connectionUpdate:
            let update = event as! FirewallConnectionUpdate
            self.process(update: update)
            
        case .dnsUpdate:
            let update = event as! FirewallDNSUpdate
            self.process(dnsUpdate: update)
            
        case .query:
            let query = event as! FirewallQuery
            self.process(query: query)
            
        case .socketListener:
            let socketListen = event as! SocketListen
            self.process(listen: socketListen)
                                 
        default: ()
        }
    }
    
    func process(listen: SocketListen) {
        connectionState.listen(listen)
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
                
        let location = self.ipdb?.find(query.remoteSocket.address.representation)

        query.remoteURL = remoteURL
        query.remoteProtocol = remoteProtocol
        
        query.localURL = localURL
        query.localProtocol = localProtocol
        
        query.location = location
        
        decisionEngine.append(query)
    }
    
    func eventTriggered(event: BaseEvent) {
        let event = event as! DecisionMadeEvent
        let id = event.query.id
        let decision = event.decision.toInt()
        
        kextComm.postDecision(id: id, allowed: decision)
    }
}
