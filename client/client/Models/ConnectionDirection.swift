//
//  ConnectionDirection.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 9/4/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


enum ConnectionDirection : CaseIterable {
    case inbound
    case outbound
    
    var description : String {
        switch self {
        case .inbound: return "Inbound"
        case .outbound : return "Outbound"
        }
    }
}


