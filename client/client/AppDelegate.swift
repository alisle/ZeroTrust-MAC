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
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
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
        window.contentView = NSHostingView(rootView: ContentView().environmentObject(main.currentConnections))
        
        window.makeKeyAndOrderFront(nil)
        
        setupStatusBar()
    }
    
    func setupStatusBar() {
        let icon = NSImage(named: "StatusBarIcon")
        icon?.isTemplate = false
        
        statusItem.menu = statusMenu
        statusItem.button?.image = icon
        //statusItem.image = icon
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        main.exitPoint()
    }


}

