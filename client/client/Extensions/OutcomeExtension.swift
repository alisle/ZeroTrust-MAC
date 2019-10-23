//
//  ConnectionExtension.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/17/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import SwiftUI

extension Outcome {
    var color : Color {
        get {
            switch self {
            case .unknown : return Color.gray
            case .allowed : return Color.green
            case .blocked : return Color.red
            case .quarantined : return Color.red
            case .isolated: return Color.red
            }
        }
    }
}
