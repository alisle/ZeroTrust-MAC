//
//  Category.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 11/25/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

enum Category : CaseIterable, Identifiable {
    case latest
    case five
    case fifteen
    case thirty
    case sixty
    
    var id : String {
        get { return self.description }
    }
    
    var description : String {
        switch self {
        case .latest: return "Latest"
        case .five: return "5 Minutes Ago"
        case .fifteen: return "15 Minutes Ago"
        case .thirty: return "30 Minutes Ago"
        case .sixty: return "60 Minutes Ago"
        }
    }
    
    var bounds : (Int, Int) {
        switch self {
        case .latest: return (0, 5)
        case .five: return (5, 15)
        case .fifteen: return (15, 30)
        case .thirty: return (30, 60)
        case .sixty: return (60, 120)
        }
    }
    
}
