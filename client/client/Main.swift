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

    //let serviceState = ServiceState()
    
    // States
    let connectionCounts = ConnectionCounts()
    let locations = Locations()
    let allConnections = AllConnections()
    let allListens = AllListens()
    let queries = Queries()
    let enabledServices = EnabledServices()
    let allRules : AllRules

    var enabled : Bool {
        get {
            return self.enabledServices.enabled
        }
        
        set {
            switch(newValue) {
            case true: EventManager.shared.triggerEvent(event: BaseEvent(.FirewallEnabled))
            case false: EventManager.shared.triggerEvent(event: BaseEvent(.FirewallDisabled))
            }
        }
    }
    
    var denyMode : Bool {
        get {
            return self.enabledServices.denyMode
        }
        set {
            switch(newValue) {
            case true: EventManager.shared.triggerEvent(event: BaseEvent(.StartDenyMode))
            case false: EventManager.shared.triggerEvent(event: BaseEvent(.StopDenyMode))
            }
        }
    }
    
    var inspectMode : Bool {
        get {
            return self.enabledServices.inspectMode
        }
        set {
            switch(newValue) {
            case true: EventManager.shared.triggerEvent(event: BaseEvent(.StartInspectMode))
            case false: EventManager.shared.triggerEvent(event: BaseEvent(.StopInspectMode))
            }
        }
    }
    
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
        
        self.allRules = AllRules(rules: Rules.load())
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
                EventManager.shared.triggerEvent(event: RulesChangedEvent(rules:results))
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

func generateFirewallQuery(hasLocation: Bool = true ) -> FirewallQuery {
    let query = FirewallQuery(
        tag: UUID(),
        id: UInt32.random(in: 1..<40000),
        timestamp: Date().timeIntervalSince1970,
        version: .OutboundTCPV4,
        remoteSocket: generateRemoteSocket(),
        localSocket: generateLocalSocket(),
        process: generateProcessInfo()
    )
    if hasLocation {
        query.location = generateIP2LocationRecord()
    }
    
    return query
}

func generateRemoteSocket() -> SocketAddress {
    let remotePort = [ 80, 443, 22, 21, 8100].randomElement()
    let addresses = [ "41.111.221.137", "159.133.25.245", "5.52.20.109", "47.134.92.77",
                      "135.103.201.30", "68.201.84.111", "98.181.189.80", "1.124.8.150",
                      "94.62.192.225", "196.142.11.103", "116.107.170.84", "161.128.90.145",
                      "203.57.95.112", "117.57.83.46", "77.168.59.226", "100.196.38.176",
                      "66.0.184.214","11.4.123.219","240.138.102.221","242.104.216.219",
                      "23.161.174.226","200.223.1.75","145.70.40.208", "68.12.228.61",
                      "207.209.151.29", "200.144.11.208", "18.164.155.37","145.56.162.174",
                      "228.1.63.60","108.74.5.158","10.244.231.189","134.174.113.246",
                      "81.6.53.101","100.121.164.1","62.152.60.228","90.58.71.198",
                      "194.49.167.180","212.52.33.216","151.249.236.242","207.184.191.10",
                      "235.222.89.219","245.137.231.1","180.25.238.8","239.120.152.64",
                      "193.79.237.81","119.119.39.230","196.141.241.244","248.51.35.58",
                      "1.214.136.144","43.13.177.223","231.3.201.82","76.213.40.23",
                      "218.79.58.81","142.201.119.62","236.187.9.146","139.19.156.42",
                      "102.61.154.68","109.228.67.123","90.218.24.100","58.77.236.135",
                      "135.112.88.80","134.112.26.147","213.242.60.25","64.41.99.212"]
    
    return SocketAddress(address: IPAddress(addresses.randomElement()!)!, port: remotePort!)
}

func generateLocalSocket() -> SocketAddress {
    let localPort = Int.random(in: 1025..<40000)
    return SocketAddress(address: IPAddress("0.0.0.0")!, port: localPort)
}

func generateTCPConnection(direction: ConnectionDirection = .outbound) -> TCPConnection {
    return TCPConnection(
        tag: UUID(),
        timestamp: Date().timeIntervalSince1970,
        inbound: direction == .inbound,
        process: generateProcessInfo(),
        remoteSocket: generateRemoteSocket(),
        localSocket: generateLocalSocket(),
        outcome: Outcome.allowed
    )
}


func generateFirewallSocketListen() -> SocketListen {
    return SocketListen(
        tag: UUID(),
        timestamp: Date().timeIntervalSince1970,
        localSocket: generateLocalSocket(),
        process: generateProcessInfo()
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
        connection: generateTCPConnection(direction: direction),
        location: includeLocation ? generateIP2LocationRecord() : nil,
        remoteURL: "www.google.com",
        portProtocol: remoteProtocol
    )
    
    return connection
}

#endif
