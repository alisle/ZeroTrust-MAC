//
//  ProcessHistoryCache.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/30/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation


class ProcessHistoryCache  : HistoryCache, EventListener  {
    public static let shared = ProcessHistoryCache()
    
    public func registerListeners() {
        EventManager.shared.addListener(type: .OpenedOutboundConnection, listener: self)
        self.trim()
    }
    
    
    func eventTriggered(event: BaseEvent) {
        let event = event as! OpenedOutboundConnectionEvent
        guard let sha = event.connection.process.sha256 else {
            return
        }

        process(key: sha, timestamp: event.connection.startTimestamp)
    }
}
