//
//  EntryPoint.swift
//  client
//
//  Created by Alex Lisle on 8/12/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import Logging
import IP2Location

class Main {
    private let logger = Logger(label: "com.zerotrust.client.Main")
    private let consumerQueue = DispatchQueue(label: "com.zeortrust.mac.consumerQueue", attributes: .concurrent)

    private let consumer : Consumer
    private let decisionEngine = DecisionEngine()
    private let rulesDispatcher = RulesDispatcher()
    private let connectionState = ConnectionState()
    private let notifications = NotficiationsManager()
    
    private let dnsCache = DNSCache()
    private let protocolCache = ProtocolCache()
    private let processManager = ProcessManager()
    
    
    private let kextComm : KextComm
    private let ipdb : IP2DBLocate?
    private let preferences : Preferences
    private let pipline : Pipeline

    let serviceState = ServiceState()
    let viewState = ViewState()
    
    // States
    let connectionCounts = ConnectionCounts()
    let locations = Locations()
    let allConnections = AllConnections()
    
    init() {                
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
        
        self.kextComm = KextComm(processManager: self.processManager)
        
        self.pipline = Pipeline(
            decisionEngine: decisionEngine,
            connectionState: connectionState,
            dnsCache: dnsCache,
            protocolCache: protocolCache,
            ipdb: ipdb,
            kextComm: kextComm
        )
        
        self.consumer = Consumer(
            pipeline: pipline,
            kextComm: kextComm
        )
        
        self.preferences = Preferences.load()!
        
        ProcessHistoryCache.shared.registerListeners()
        RemoteHistoryCache.shared.registerListeners()
    }
    
    func entryPoint() {
        serviceState.enabled = true
        consumerQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.consumer.loop()
        }
        
        startTimers()
    }
    
    private func startTimers() {
        rulesUpdate()
    }
    
    func getRules() {
        logger.info("Getting Rules")
        self.rulesDispatcher.getRules { [weak self] results, errorMessage in
            if let results = results {
                self?.decisionEngine.set(rules: results)
                self?.viewState.rules = results
            } else {
                self?.logger.error("\(errorMessage)")
            }
        }
    }
    
    private func rulesUpdate() {
        let mins = TimeInterval(preferences.rulesUpdateInterval * 60)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + mins)  {
            self.getRules()
            self.rulesUpdate()
        }
    }
        
    
    func exitPoint() {
        
    }


}


#if DEBUG
func generateTestRules() -> Rules {
    var json : JSONRules  = Helpers.loadJSON("rules.json")
    json.hostnames.sort()
    json.domains.sort()
    
    return json.convert()
}

func generateProcessInfo(_ generatePeers : Bool = true, _ numberOfPeers : Int = 4) -> ProcessDetails {
    let process = ["Chrome.app", "/usr/bin/ssh", "WhatsApp.app"].randomElement()

    let parent = (generatePeers) ? generateProcessInfo(false) : nil
    let peers = (generatePeers) ? (0..<numberOfPeers).map{ _ in generateProcessInfo(false) } : []
    
    print("Theses are peers \(peers)")
    return ProcessDetails(
        pid: Int.random(in: 1000...4000),
        ppid: 1020,
        uid: 1000,
        username: "alisle",
        command: process,
        path: "/usr/bin/ssh",
        parent: parent,
        bundle: nil,
        appBundle: nil,
        sha256: "012012",
        md5: "1231",
        peers: peers
    )
}

func generateTCPConnection() -> TCPConnection {
    let localPort = Int.random(in: 1025..<40000)
    let remotePort = [ 80, 443, 22, 21, 8100].randomElement()

    return TCPConnection(
        tag: UUID(),
        timestamp: Date().timeIntervalSince1970,
        inbound: false,
        process: generateProcessInfo(),
        remoteSocket: SocketAddress(address: IPAddress("192.168.2.3")!, port: remotePort!),
        localSocket: SocketAddress(address: IPAddress("0.0.0.0")!, port: localPort),
        outcome: Outcome.allowed
    )
}


func generateIP2LocationRecord() -> IP2LocationRecord? {
    if let filepath = Bundle.main.url(forResource: "IP2LOCATION-LITE-DB11", withExtension: "BIN") {
        do {
            let db = try IP2DBLocate(file: filepath)
            return db.find("8.8.8.8")
        } catch  {
            return nil
        }
    }
    
    return nil
}

func generateTestConnection(direction: ConnectionDirection, includeLocation : Bool = false) -> Connection {
    let tcpConnection = generateTCPConnection()
    let protocolCache = ProtocolCache()
    let remoteProtocol = protocolCache.get(tcpConnection.remoteSocket.port)
    let connection = Connection(
        connection: generateTCPConnection(),
        location: includeLocation ? generateIP2LocationRecord() : nil,
        remoteURL: "www.google.com",
        portProtocol: remoteProtocol
    )
    
    return connection
}

#endif
