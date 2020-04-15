//
//  DecisionMadeEvent.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/9/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation


public class DecisionMadeEvent : BaseEvent {
    let decision : Outcome
    let query: FirewallQuery
    
    init(query: FirewallQuery, decision: Outcome) {
        self.query = query
        self.decision = decision
        super.init(.DecisionMade)
    }
}
