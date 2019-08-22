//
//  ViewLengths.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 8/21/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

enum ViewLength : String, CaseIterable {
    case current
    case five
    case ten
    case thirty
    case hour
    
    var description : String {
        switch self {
        case .current: return "Current"
        case .five: return "5 Minutes"
        case .ten: return "10 Minutes"
        case .thirty: return "30 Minutes"
        case .hour: return "1 Hour"
        }
    }
    
    var length : Int {
        switch self {
        case .current : return 0
        case .five : return 5
        case .ten: return 10
        case .thirty: return 30
        case .hour: return 60
        }
    }
    
    static func max() -> Int {
        return self.hour.length
    }
}
