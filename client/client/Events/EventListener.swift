//
//  EventListener.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 2/25/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation


public protocol EventListener {
    func eventTriggered(event: BaseEvent)
}
