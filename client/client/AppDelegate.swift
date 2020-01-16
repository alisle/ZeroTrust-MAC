//
//  AppDelegate.swift
//  client
//
//  Created by Alex Lisle on 6/20/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ServiceStateListener {

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
    
    func serviceStateChanged(type: ServiceStateType, serviceEnabled: Bool) {
        switch type {
        case .enabled:
            switch serviceEnabled {
            case true:
                enabledMenuItem.title = "Disable Service..."
                enabledMenuItem.image = disabledIcon
            case false:
                enabledMenuItem.title = "Enable Service..."
                enabledMenuItem.image = enabledIcon
            }
            
        case .inspectMode:
            switch serviceEnabled {
            case true:
                inspectModeMenuItem.title = "Stop Inspect Mode..."
            case false:
                inspectModeMenuItem.title = "Start Inspect Mode..."
            }
            
        case .denyMode:
            switch serviceEnabled {
                case true:
                    denyModeMenuItem.title = "Stop Deny Mode..."
                case false:
                    denyModeMenuItem.title = "Start Deny Mode..."
            }
            
        }
    }
    
    @IBAction func quitClicked(_ sender: Any) {
        cleanup()        
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func enabledClicked(_ sender: Any) {
        main.serviceState.enabled.toggle()
    }
    
    @IBAction func denyModeClicked(_ sender: Any) {
        main.serviceState.denyMode.toggle()
    }
    
    @IBAction func inspectModeClicked(_ sender: Any) {
        main.serviceState.inspectMode.toggle()
    }
    
    @IBAction func showRulesClicked(_ sender: Any) {
        print("opening rules window")
        rulesWindow.makeKeyAndOrderFront(nil)
    }
    
    @IBAction func showConnectionsClicked(_ sender: Any) {
        print("opening connections window")
        connectionsWindow.makeKeyAndOrderFront(nil)
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
        connectionsWindow.contentView = NSHostingView(rootView: ConnectionsView().environmentObject(main.viewState).environmentObject(main.serviceState))
    }

    func createRulesWindow() {
        rulesWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        rulesWindow.isReleasedWhenClosed = false
        rulesWindow.center()
        rulesWindow.setFrameAutosaveName("Rules Window")
        rulesWindow.contentView = NSHostingView(rootView: RulesView().environmentObject(main.viewState))
        
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createConnectionsWindow()
        createRulesWindow()
        main.entryPoint()
        
        main.serviceState.addListener(type: .enabled, listener: self)
        main.serviceState.addListener(type: .inspectMode, listener: self)
        main.serviceState.addListener(type: .denyMode, listener: self)
                
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
        main.serviceState.enabled = false
        main.exitPoint()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        cleanup()
    }


}

