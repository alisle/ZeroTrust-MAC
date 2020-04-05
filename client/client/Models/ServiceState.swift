//
//  ServiceState.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 1/16/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
import Combine

public enum ServiceStateType : CaseIterable {
    case enabled,
    inspectMode,
    denyMode
}

class ServiceState: ObservableObject {
    
    private let stateQueue = DispatchQueue(label: "com.zerotrust.mac.service.state.queue", attributes: .concurrent)
    
    private var _enabled : Bool = true
    private var _inspectMode : Bool = false
    private var _denyMode : Bool = false
    
    var objectWillChange = PassthroughSubject<Void, Never>()
    
    var enabled : Bool {
        set {
            _enabled = newValue
            switch(newValue) {
            case true: EventManager.shared.triggerEvent(event: BaseEvent(.FirewallEnabled))
            case false: EventManager.shared.triggerEvent(event: BaseEvent(.FirewallDisabled))
            }
            
            self.objectWillChange.send()
        }
        
        get { return _enabled }
    }
    
    var inspectMode : Bool {
        set {
            _inspectMode = newValue
            switch(newValue) {
            case true: EventManager.shared.triggerEvent(event: BaseEvent(.StartInspectMode))
            case false: EventManager.shared.triggerEvent(event: BaseEvent(.StopInspectMode))
            }
            self.objectWillChange.send()

        }
        get { return _inspectMode }
    }
    
    var denyMode : Bool {
        set {
            _denyMode = newValue
            
            switch(newValue) {
            case true: EventManager.shared.triggerEvent(event: BaseEvent(.StartDenyMode))
            case false: EventManager.shared.triggerEvent(event: BaseEvent(.StopDenyMode))
            }

            self.objectWillChange.send()
        }
        
        get { return _denyMode }
    }

        
}
