//
//  AppDelegate.swift
//  client
//
//  Created by Alex Lisle on 6/20/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Cocoa
import SwiftUI
import Logging

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, EventListener {
    var logger = Logger(label: "com.zerotrust.client.AppDeletegate")

    var connectionsWindow: NSWindow!
    var rulesWindow: NSWindow!
        
    let main = Main()
    
    let disabledIcon = NSImage(named: "DisabledEthernet")
    let enabledIcon = NSImage(named: "EnabledEthernet")
    let inspectModeIcon = NSImage(named: "InspectMode")
    let connectionsIcon = NSImage(named: "Connections")
    let statusBarIcon = NSImage(named: "StatusBarIcon")
    let denyModeIcon = NSImage(named: "DenyMode")
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var enabledMenuItem: NSMenuItem!
    @IBOutlet weak var inspectModeMenuItem: NSMenuItem!
    @IBOutlet weak var showConnectionsMenuItem: NSMenuItem!
    @IBOutlet weak var quitMenuItem: NSMenuItem!
    @IBOutlet weak var denyModeMenuItem: NSMenuItem!
    @IBOutlet weak var showRulesMenuItem: NSMenuItem!
    

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    func eventTriggered(event: BaseEvent) {
        switch event.type {
        case .FirewallEnabled:
            enabledMenuItem.title = "Disable Service..."
            enabledMenuItem.image = disabledIcon
        case .FirewallDisabled:
            enabledMenuItem.title = "Enable Service..."
            enabledMenuItem.image = enabledIcon
        case .StartInspectMode:
            inspectModeMenuItem.title = "Stop Inspect Mode..."
        case .StopInspectMode:
            inspectModeMenuItem.title = "Start Inspect Mode..."
        case .StartDenyMode:
            denyModeMenuItem.title = "Stop Deny Mode..."
        case .StopDenyMode:
            denyModeMenuItem.title = "Start Deny Mode..."
        default: ()
        }
    }
    
    @IBAction func quitClicked(_ sender: Any) {
        cleanup()        
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func enabledClicked(_ sender: Any) {
        main.enabled.toggle()
    }
    
    @IBAction func denyModeClicked(_ sender: Any) {
        main.denyMode.toggle()
    }
    
    @IBAction func inspectModeClicked(_ sender: Any) {
        main.inspectMode.toggle()
    }
    
    @IBAction func showRulesClicked(_ sender: Any) {
        logger.info("opening rules window")
        rulesWindow.makeKeyAndOrderFront(self)
    }
    
    @IBAction func showConnectionsClicked(_ sender: Any) {
        logger.info("opening connections window")
        connectionsWindow.makeKeyAndOrderFront(self)
    }
    
    
    @IBAction func updateRulesClicked(_ sender: Any) {
        main.getRules()
    }
    

    func createConnectionsWindow() {
        connectionsWindow = NSWindow(
               contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
               styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
               backing: .buffered, defer: false)
        connectionsWindow.isReleasedWhenClosed = false
        connectionsWindow.center()
        connectionsWindow.setFrameAutosaveName("Connections Window")
        connectionsWindow.contentView = NSHostingView(rootView: ConnectionRootView()
            .environmentObject(main.allRules)
            .environmentObject(main.enabledServices)
            .environmentObject(main.connectionCounts)
            .environmentObject(main.locations)
            .environmentObject(main.allConnections)
            .environmentObject(main.queries)
            .environmentObject(main.allListens)
        )        
    }

    
    func createRulesWindow() {
        rulesWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        rulesWindow.isReleasedWhenClosed = false
        rulesWindow.center()
        rulesWindow.setFrameAutosaveName("Rules Window")
        rulesWindow.contentView = NSHostingView(rootView: RulesRootView()
            .environmentObject(main.allRules)
            .environmentObject(main.enabledServices)
            .environmentObject(main.connectionCounts)
            .environmentObject(main.locations)
            .environmentObject(main.allConnections)
            .environmentObject(main.queries)
            .environmentObject(main.allListens)
        )
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        
        createConnectionsWindow()
        createRulesWindow()
        main.enabled = true
        main.entryPoint()
        
        EventManager.shared.addListener(type: .FirewallEnabled, listener: self)
        EventManager.shared.addListener(type: .FirewallDisabled, listener: self)

        EventManager.shared.addListener(type: .StartInspectMode, listener: self)
        EventManager.shared.addListener(type: .StopInspectMode, listener: self)

        EventManager.shared.addListener(type: .StartDenyMode, listener: self)
        EventManager.shared.addListener(type: .StopDenyMode, listener: self)
        
        setupStatusBar()
    }
    
    func setupStatusBar() {
        
        disabledIcon?.isTemplate = true
        enabledIcon?.isTemplate = true
        inspectModeIcon?.isTemplate = true
        connectionsIcon?.isTemplate = true
        statusBarIcon?.isTemplate = true
        denyModeIcon?.isTemplate = true

        statusItem.menu = statusMenu
        statusItem.button?.image = statusBarIcon
        
        
        enabledMenuItem.title = "Disable Service..."
        enabledMenuItem.image = disabledIcon

        
        denyModeMenuItem.image = denyModeIcon
        inspectModeMenuItem.image = inspectModeIcon
        showConnectionsMenuItem.image = connectionsIcon
        
    }
    
    func cleanup() {
        self.main.enabled = false
        main.exitPoint()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        cleanup()
    }


}

