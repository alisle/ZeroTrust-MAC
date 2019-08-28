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
    let Quarantine = NSImage(named: "Quarantine")
    
    var enabled = true
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var enabledMenuItem: NSMenuItem!
    @IBOutlet weak var quarantineMenuItem: NSMenuItem!
    @IBOutlet weak var showConnectionsMenuItem: NSMenuItem!
    @IBOutlet weak var quitMenuItem: NSMenuItem!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func enabledClicked(_ sender: Any) {
        enabled.toggle()
        
        if enabled {
            enableService()
        } else {
            disableService()
        }
    }
    
    @IBAction func quarantineClicked(_ sender: Any) {
        
    }
    
    @IBAction func showConnectionsClicked(_ sender: Any) {
        window.makeKeyAndOrderFront(nil)
    }
    
    private func enableService(){
        enabledMenuItem.title = "Disable Service..."
        enabledMenuItem.image = disabledIcon
        main.enable()
    }
    
    private func disableService() {
        enabledMenuItem.title = "Enable Service..."
        enabledMenuItem.image = enabledIcon
        main.disable()
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
        let icon = NSImage(named: "StatusBarIcon")
        icon?.isTemplate = false
        
        statusItem.menu = statusMenu
        statusItem.button?.image = icon
        
        enableService()
        
        quarantineMenuItem.image = Quarantine

    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        main.disable()
        main.exitPoint()
    }


}

