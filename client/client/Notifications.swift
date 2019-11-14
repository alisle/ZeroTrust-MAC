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
        notification.identifier = "com.zeortrust.mac.notification.connection.\(connection.id)"
        notification.title = "New Connection"
        notification.subtitle = connection.remoteURL ?? connection.remoteAddress
        notification.informativeText = "\(connection.displayName) made a connect to \(connection.remoteURL ?? connection.remoteAddress)"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func connectionChanged(_ connection: Connection) {
        if self.showNewConnections && connection.state == .connected {
            newConnection(connection)
        }
    }
}
