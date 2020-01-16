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
    inspectModeBlocked,
    denyModeBlocked,
    unknown
    
    var description : String {
        switch self {
        case .unknown : return "Unknown"
        case .allowed : return "Allowed"
        case .blocked : return "Blocked"
        case .inspectModeBlocked : return "Inspect Mode - Blocked"
        case .denyModeBlocked: return "Deny Mode - Blocked"
        }
    }
}
