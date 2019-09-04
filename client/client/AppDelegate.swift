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
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let main = Main()
    
    let disabledIcon = NSImage(named: "DisabledEthernet")
    let enabledIcon = NSImage(named: "EnabledEthernet")
    let quarantineIcon = NSImage(named: "Quarantine")
    let connectionsIcon = NSImage(named: "Connections")
    let statusBarIcon = NSImage(named: "StatusBarIcon")
    let isolateIcon = NSImage(named: "Isolate")
    
    
    var enabled = true
    var isolation = false
    var quarantine = false
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var enabledMenuItem: NSMenuItem!
    @IBOutlet weak var quarantineMenuItem: NSMenuItem!
    @IBOutlet weak var showConnectionsMenuItem: NSMenuItem!
    @IBOutlet weak var quitMenuItem: NSMenuItem!
    @IBOutlet weak var isolationMenuItem: NSMenuItem!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @IBAction func quitClicked(_ sender: Any) {
        cleanup()        
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func enabledClicked(_ sender: Any) {
        enabled.toggle()
        
        switch enabled {
        case true:
            enabledMenuItem.title = "Disable Service..."
            enabledMenuItem.image = disabledIcon
            main.enable()
        case false:
            enabledMenuItem.title = "Enable Service..."
            enabledMenuItem.image = enabledIcon
            main.disable()
        }
    }
    
    @IBAction func isolationClicked(_ sender: Any) {
        isolation.toggle()
        switch isolation {
        case true:
            isolationMenuItem.title = "Stop Isolation Mode..."
            main.isolate(enable: true)
        case false:
            isolationMenuItem.title = "Start Isolation Mode..."
            main.isolate(enable: false)
        }
    }
    
    @IBAction func quarantineClicked(_ sender: Any) {
        quarantine.toggle()
        switch quarantine {
        case true:
            quarantineMenuItem.title = "Stop Quarantine Mode..."
            main.quanrantine(enable: true)
        case false:
            quarantineMenuItem.title = "Start Quarantine Mode..."
            main.quanrantine(enable: false)
        }
    }
    
    @IBAction func showConnectionsClicked(_ sender: Any) {
        window.makeKeyAndOrderFront(nil)
    }
    
    
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")

        main.entryPoint()
        main.enable()
        
        window.contentView = NSHostingView(rootView: ContentView().environmentObject(main.currentConnections))
        
        //window.makeKeyAndOrderFront(nil)
        
        setupStatusBar()
    }
    
    func setupStatusBar() {
        
        disabledIcon?.isTemplate = true
        enabledIcon?.isTemplate = true
        quarantineIcon?.isTemplate = true
        connectionsIcon?.isTemplate = true
        statusBarIcon?.isTemplate = true
        isolateIcon?.isTemplate = true

        statusItem.menu = statusMenu
        statusItem.button?.image = statusBarIcon
        
        
        enabledMenuItem.title = "Disable Service..."
        enabledMenuItem.image = disabledIcon
        main.enable()

        
        isolationMenuItem.image = isolateIcon
        quarantineMenuItem.image = quarantineIcon
        showConnectionsMenuItem.image = connectionsIcon
        
    }
    
    func cleanup() {
        main.disable()
        main.exitPoint()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        cleanup()
    }


}

