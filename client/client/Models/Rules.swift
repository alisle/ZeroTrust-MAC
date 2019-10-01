//
//  Rules.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 9/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


struct Rules : Codable {
    var domains : [String]
    var hostnames : [String]
}
