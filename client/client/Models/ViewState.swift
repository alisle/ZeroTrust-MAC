//
//  CurrentConnections.swift
//  client
//
//  Created by Alex Lisle on 8/12/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ViewState : ObservableObject {
    @Published var connections  = [ ViewLength: Set<Connection>]()
    @Published var enabled = true
    @Published var rules : Rules
    
    init() {
        let jsonRules : JSONRules = Helpers.loadJSON("rules.json")
        self.rules = jsonRules.convert()
        
        for view in ViewLength.allCases {
            connections[view] = []
        }
    }
}
