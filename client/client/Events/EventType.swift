//
//  EventType.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 2/25/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation

public enum EventType : CaseIterable {
    case
    FirewallEnabled,
    FirewallDisabled,
    
    StartInspectMode,
    StopInspectMode,
    
    StartDenyMode,
    StopDenyMode,
    
    OpenedOutboundConnection,
    ClosedOutboundConnection,
    
    ConnectionChanged,
    DecisionMade,
    
    RulesChanged
}
