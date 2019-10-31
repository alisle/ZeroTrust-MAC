//
//  EntryPoint.swift
//  client
//
//  Created by Alex Lisle on 8/12/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

class Main {
    private let consumer : Consumer
    private let decisionEngine = DecisionEngine()
    private let rulesDispatcher = RulesDispatcher()
    private let connectionState = ConnectionState()
    private let preferences : Preferences
    private let consumerQueue = DispatchQueue(label: "com.zeortrust.mac.consumerQueue", attributes: .concurrent)
    
    let viewState : ViewState = ViewState()

    init() {
        self.consumer = Consumer(decisionEngine: decisionEngine, state: connectionState)
        connectionState.addListener(listener: viewState)
        self.preferences = Preferences.load()!        
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
    
    func enable() {
        let _ = consumer.open()
        viewState.enabled = true
    }
    
    func disable() {
        consumer.close()
        viewState.enabled = false
    }
        
    func isolate(enable: Bool) {
        consumer.isolate(enable: enable)
    }
    
    func quanrantine(enable: Bool) {
        consumer.quarantine(enable: enable)
    }
    func getRules() {
        print("Getting Rules")
        self.rulesDispatcher.getRules { [weak self] results, errorMessage in
            if let results = results {
                self?.decisionEngine.set(rules: results)
                self?.viewState.rules = results
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
    
    
    func exitPoint() {
        
    }
    
    

}
