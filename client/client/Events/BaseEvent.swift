//
//  BaseEvent.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 2/25/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation

public class BaseEvent {
    public let type : EventType
    
    init(_ type: EventType) {
        self.type = type
    }
}

