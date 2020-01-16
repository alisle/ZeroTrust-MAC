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
    private var listeners : [ ServiceStateType:[ServiceStateListener]] = [:]
    
    private var _enabled : Bool = true
    private var _inspectMode : Bool = false
    private var _denyMode : Bool = false
    
    var objectWillChange = PassthroughSubject<Void, Never>()
    
    var enabled : Bool {
        set {
            _enabled = newValue
            triggerListener(type: .enabled, value: newValue)
            self.objectWillChange.send()
        }
        
        get { return _enabled }
    }
    
    var inspectMode : Bool {
        set {
            _inspectMode = newValue
            triggerListener(type: .inspectMode, value: newValue)
            self.objectWillChange.send()

        }
        get { return _inspectMode }
    }
    
    var denyMode : Bool {
        set {
            _denyMode = newValue
            triggerListener(type: .denyMode, value: newValue)
            self.objectWillChange.send()
        }
        
        get { return _denyMode }
    }

    
    
    init() {
        ServiceStateType.allCases.forEach {  listeners[$0] = [] }
    }
    
    private func triggerListener(type: ServiceStateType, value: Bool) {
        self.stateQueue.sync { [weak self] in
            guard let self = self else {
                return
            }
            self.listeners[type]?.forEach { $0.serviceStateChanged(type: type, serviceEnabled: value) }
        }
    }
    
    func addListener(type : ServiceStateType, listener: ServiceStateListener) {
        self.stateQueue.sync { [weak self] in
            guard let self = self else {
                return
            }
                        
            self.listeners[type]!.append(listener)
        }
    }
}
