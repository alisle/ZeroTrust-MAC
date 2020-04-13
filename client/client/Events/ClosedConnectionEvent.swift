//
//  ClosedOutboundConnectionEvent.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/18/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
public class ClosedConnectionEvent : BaseEvent {
    let connection : Connection
    
    init(connection : Connection) {
        self.connection = connection
        super.init(.ClosedConnection)
    }
}
