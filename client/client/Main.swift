//
//  EntryPoint.swift
//  client
//
//  Created by Alex Lisle on 8/12/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


class Main {
    let consumerThread : ConsumerThread
    let currentConnections : CurrentConnections = CurrentConnections()
    let decisionEngine = DecisionEngine()
    let rulesDispatcher = RulesDispatcher()
    let connectionState = ConnectionState()
    let preferences : Preferences

    init() {
        self.consumerThread = ConsumerThread(decisionEngine: decisionEngine, state: connectionState)
        self.preferences = Preferences.load()!
    }
    
    func entryPoint() {
        consumerThread.start()
        getRules()
        startTimers()
    }
    
    private func startTimers() {
        connectionsUpdate()
        rulesUpdate()
        connectionsStateUpdate()
    }
    
    func enable() {
        let _ = consumerThread.open()
        currentConnections.enabled = true
    }
    
    func disable() {
        self.currentConnections.connections = [ ViewLength: [Connection]]()
        consumerThread.close()
        currentConnections.enabled = false
    }
        
    func isolate(enable: Bool) {
        consumerThread.isolate(enable: enable)
    }
    
    func quanrantine(enable: Bool) {
        consumerThread.quarantine(enable: enable)
    }
    
    private func connectionsStateUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            self.connectionState.trim()
            self.connectionsStateUpdate()
        }
    }
    
    private func connectionsUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.currentConnections.enabled {
                self.currentConnections.connections = self.consumerThread.connections                
            }
            
            self.connectionsUpdate()
        }
    }
    
    func getRules() {
        print("getting rules")
        self.rulesDispatcher.getRules { [weak self] results, errorMessage in
            if let results = results {
                self?.decisionEngine.set(rules: results)
            } else {
                print(errorMessage)
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
    
    func getAllConnections() -> [ViewLength: [Connection]] {
        return consumerThread.connections
    }

    func getConnections(filter: ViewLength) -> [Connection] {
        return consumerThread.connections[filter]!
    }
    
    func exitPoint() {
        
    }
    
    

}
