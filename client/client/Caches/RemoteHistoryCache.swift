//
//  remoteHistoryCache.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/1/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation


class RemoteHistoryCache : HistoryCache, EventListener {
    public static let shared = RemoteHistoryCache()
    
    public func registerListeners() {
        EventManager.shared.addListener(type: .OpenedOutboundConnection, listener: self)
        self.trim()
    }

 
    func eventTriggered(event: BaseEvent) {
        let event = event as! OpenedOutboundConnectionEvent
        let url = event.connection.remoteDisplayAddress 
        process(key: url, timestamp: event.connection.startTimestamp)
    }

}
