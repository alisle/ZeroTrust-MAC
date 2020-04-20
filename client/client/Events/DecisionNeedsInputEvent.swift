//
//  DecisionNeedsInputEvent.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/20/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation

public class DecisionNeedsInputEvent : BaseEvent {
    let query : FirewallQuery
    
    init(query: FirewallQuery) {
        self.query = query
        super.init(.DecisionNeedsInput)
    }
}
