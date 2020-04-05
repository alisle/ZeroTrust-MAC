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
