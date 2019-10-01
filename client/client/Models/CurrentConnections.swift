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

class CurrentConnections : ObservableObject {
    @Published var connections  = [ ViewLength: [Connection]]()
    @Published var enabled = true
}
