//
//  Outcome.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 9/3/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

enum Outcome : Int {
    case allowed = 0,
    blocked,
    inspectModeAllowed,
    inspectModeBlocked,
    denyModeBlocked,
    unknown
    
    var description : String {
        switch self {
        case .unknown : return "Unknown"
        case .allowed : return "Allowed"
        case .blocked : return "Blocked"
        case .inspectModeAllowed : return "Inspect Mode - Allowed"
        case .inspectModeBlocked : return "Inspect Mode - Blocked"
        case .denyModeBlocked: return "Deny Mode - Blocked"
        }
    }
    
    func toInt() -> UInt32 {
        switch self {
        case .allowed : return 0
        case .blocked : return 1
        case .inspectModeAllowed : return 2
        case .inspectModeBlocked : return 3
        case .denyModeBlocked: return 4
        case .unknown : return 99
        }
    }
}
