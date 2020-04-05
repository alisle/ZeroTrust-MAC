//
//  ConnectionDetailWindow.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/22/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Cocoa
import SwiftUI


class DetailWindowController<RootView : View>: NSWindowController {
    convenience init(rootView: RootView) {
        let hostingController = NSHostingController(rootView: rootView)
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 800, height: 600))
        window.titleVisibility = .hidden
        
        self.init(window: window)
    }
}
