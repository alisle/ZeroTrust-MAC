//
//  RecordDetails.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/20/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
import IP2Location

protocol RecordDetails {
    var location : IP2LocationRecord? { get }
    var direction : ConnectionDirection  { get }
    var process : ProcessDetails  { get }
    var remoteDisplayAddress : String  { get }
    var remoteSocket : SocketAddress  { get }
    var localSocket : SocketAddress  { get }
    
}
