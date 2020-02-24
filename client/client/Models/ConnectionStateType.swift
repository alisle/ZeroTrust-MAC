//
//  ConnectionState.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 8/21/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

enum ConnectionStateType: Int {
    case connecting = 1,
    connected,
    disconnecting,
    disconnected,
    closed,
    bound,
    unknown
    
    var description : String {
        switch self {
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .disconnecting: return "Disconnecting"
        case .disconnected: return "Disconnected"
        case .closed: return "Closed"
        case .bound: return "Bound"
        case .unknown: return "Unknown"
        }
    }
    
    var alive : Bool {
        switch self {
        case .bound: return true
        case .connected: return true
        case .connecting: return true
        default: return false
        }
    }
}
