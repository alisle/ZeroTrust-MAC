//
//  StateListener.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/23/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

protocol StateListener {
    func connectionChanged(_ connection: Connection)
}
