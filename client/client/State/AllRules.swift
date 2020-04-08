//
//  AllRules.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/8/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
import Logging

class AllRules : ObservableObject, EventListener {
    private let logger = Logger(label: "com.zerotrust.client.States.AllRules")
    @Published var rules : Rules
    
    
    init(rules: Rules) {
        self.rules = rules
        EventManager.shared.addListener(type: .RulesChanged, listener: self)
    }
    
    func eventTriggered(event: BaseEvent) {
        let event = event as! RulesChangedEvent
        self.logger.info("updating rules")
        self.rules = event.rules
    }        
}
