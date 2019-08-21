//
//  ConnectionState.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 8/21/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

enum ConnectionState: Int {
    case connecting = 1,
    connected,
    disconnecting,
    disconnected,
    closing,
    bound,
    unknown
    
    var description : String {
        switch self {
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .disconnecting: return "Disconnecting"
        case .disconnected: return "Disconnected"
        case .closing: return "Closing"
        case .bound: return "Bound"
        case .unknown: return "Unknown"
        }
    }
}
