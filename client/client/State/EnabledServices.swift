//
//  EnabledServices.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/15/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation

class EnabledServices : ObservableObject, EventListener {
    @Published var enabled : Bool = true
    @Published var inspectMode : Bool = false
    @Published var denyMode : Bool = false
    
    init() {
        EventManager.shared.addListener(type: .FirewallEnabled, listener: self)
        EventManager.shared.addListener(type: .FirewallDisabled, listener: self)
        EventManager.shared.addListener(type: .StartInspectMode, listener: self)
        EventManager.shared.addListener(type: .StopInspectMode, listener: self)
        EventManager.shared.addListener(type: .StartDenyMode, listener: self)
        EventManager.shared.addListener(type: .StopDenyMode, listener: self)
    }
    
    func eventTriggered(event: BaseEvent) {
        switch(event.type) {
        case .FirewallEnabled: self.enabled = true
        case .FirewallDisabled: self.enabled = false
            
        case .StartInspectMode: self.inspectMode = true
        case .StopInspectMode: self.inspectMode = false
            
        case .StartDenyMode: self.denyMode = true
        case .StopDenyMode: self.denyMode = false
        default: return
        }
    }
}
