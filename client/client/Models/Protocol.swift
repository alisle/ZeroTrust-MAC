//
//  Protocol.swift
//  client
//
//  Created by Alex Lisle on 8/15/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

struct Protocol : Codable {
    var name : String
    var port : Int
    var description : String
    var url: String
}
