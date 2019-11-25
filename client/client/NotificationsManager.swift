//
//  Notifications.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 11/14/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


class NotficiationsManager : StateListener {
    let showNewConnections : Bool
    
    init() {
        let preferences = Preferences.load()
        self.showNewConnections = preferences!.newConnectionNotifications
    }
    
    private func newConnection(_ connection: Connection) {
        let notification = NSUserNotification()
        notification.identifier = "com.zeortrust.mac.notification.connection.new.\(connection.id)"
        notification.title = "New Connection"
        notification.subtitle = connection.remoteURL ?? connection.remoteAddress
        notification.informativeText = "\(connection.displayName) made a connect to \(connection.remoteURL ?? connection.remoteAddress)"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func newBlocked(_ connection: Connection) {
        let notification = NSUserNotification()
        notification.identifier = "com.zeortrust.mac.notification.connection.blocked.\(connection.id)"
        notification.title = "Blocked Connection"
        notification.subtitle = connection.remoteURL ?? connection.remoteAddress
        notification.informativeText = "\(connection.displayName) to \(connection.remoteURL ?? connection.remoteAddress) has been blocked"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func newQuarantined(_ connection: Connection) {
        let notification = NSUserNotification()
        notification.identifier = "com.zerotrust.mac.notification.connection.quaranted.\(connection.id)"
        notification.title = "Quarantined"
        notification.subtitle = connection.remoteURL ?? connection.remoteAddress
        notification.informativeText = "\(connection.displayName) to \(connection.remoteURL ?? connection.remoteAddress) was quarantined"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func newIsolated(_ connection: Connection) {
        let notification = NSUserNotification()
        notification.identifier = "com.zerotrust.mac.notification.connection.isolated.\(connection.id)"
        notification.title = "In Isolation"
        notification.subtitle = connection.remoteURL ?? connection.remoteAddress
        notification.informativeText = "\(connection.displayName) to \(connection.remoteURL ?? connection.remoteAddress) was blocked, as we are isolated"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func connectionChanged(_ connection: Connection) {
        
        switch connection.outcome {
        case .allowed:
            if self.showNewConnections {
                newConnection(connection)
            }
        case .blocked: newBlocked(connection)
        case .isolated: newIsolated(connection)
        case .quarantined: newQuarantined(connection)
        case .unknown: break
        }
    }
}
