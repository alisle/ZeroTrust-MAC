//
//  ConnectionChangedEvent.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 2/25/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation

public class ConnectionChangedEvent : BaseEvent {
    let connection : Connection
    
    init(connection : Connection) {
        self.connection = connection
        super.init(.ConnectionChanged)
    }
}
