//
//  RulesChangedEvent.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/8/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation

public class RulesChangedEvent : BaseEvent {
    let rules : Rules
    
    init(rules: Rules) {
        self.rules = rules
        super.init(.RulesChanged)
    }
}
