//
//  Notifications.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 11/14/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


class NotficiationsManager : EventListener {
    let showNewConnections : Bool
    
    init() {
        let preferences = Preferences.load()
        self.showNewConnections = preferences!.newConnectionNotifications
        EventManager.shared.addListener(type: .ConnectionChanged, listener: self)
    }
    
    private func newConnection(_ connection: Connection) {
        let notification = NSUserNotification()
        notification.identifier = "com.zeortrust.mac.notification.connection.new.\(connection.id)"
        notification.title = "New Connection"
        notification.subtitle = connection.remoteURL ?? connection.remoteSocket.description
        notification.informativeText = "\(connection.process.displayName) made a connect to \(connection.remoteURL ?? connection.remoteSocket.description)"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func newBlocked(_ connection: Connection) {
        let notification = NSUserNotification()
        notification.identifier = "com.zeortrust.mac.notification.connection.blocked.\(connection.id)"
        notification.title = "Blocked Connection"
        notification.subtitle = connection.remoteURL ?? connection.remoteSocket.description
        notification.informativeText = "\(connection.process.displayName) to \(connection.remoteURL ?? connection.remoteSocket.description) has been blocked"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func newInspectModeNotification(_ connection: Connection) {
        let notification = NSUserNotification()
        notification.identifier = "com.zerotrust.mac.notification.connection.inspectmode.\(connection.id)"
        notification.title = "Inspect Mode"
        notification.subtitle = connection.remoteURL ?? connection.remoteSocket.description
        notification.informativeText = "\(connection.process.displayName) to \(connection.remoteURL ?? connection.remoteSocket.description) has been attempted"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func newDenyModeNotification(_ connection: Connection) {
        let notification = NSUserNotification()
        notification.identifier = "com.zerotrust.mac.notification.connection.denymode.\(connection.id)"
        notification.title = "Deny Mode - Blocked"
        notification.subtitle = connection.remoteURL ?? connection.remoteSocket.description
        notification.informativeText = "\(connection.process.displayName) to \(connection.remoteURL ?? connection.remoteSocket.description) was blocked, as we are in deny mode"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func eventTriggered(event: BaseEvent) {
        let event = event as! ConnectionChangedEvent
        let connection = event.connection
        
        switch connection.outcome {
        case .allowed:
            if self.showNewConnections {
                newConnection(connection)
            }
        case .inspectModeAllowed:
            if self.showNewConnections {
                newConnection(connection)
            }
        case .blocked: newBlocked(connection)
        case .denyModeBlocked: newDenyModeNotification(connection)
        case .inspectModeBlocked: newInspectModeNotification(connection)
        case .unknown: break
        }
    }
}
