//
//  DecisionEngine.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 9/10/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import Logging


class DecisionEngine : EventListener {
    let logger = Logger(label: "com.zerotrust.client.DecisionEngine")

    private var rules : Optional<Rules> = nil
    private let rulesLock = NSLock()
    private var lastUpdate = NSDate().timeIntervalSince1970
    private var inDenial = false
    
    init() {
        EventManager.shared.addListener(type: .RulesChanged, listener: self)
        EventManager.shared.addListener(type: .StartDenyMode, listener: self)
        EventManager.shared.addListener(type: .StopDenyMode, listener: self)
    }
    
    func eventTriggered(event: BaseEvent) {
        switch(event.type) {
        case .RulesChanged:
            let event = event as! RulesChangedEvent
            self.set(rules: event.rules)
        case .StartDenyMode:
            self.inDenial = true
        case .StopDenyMode:
            self.inDenial = false
        default: return
        }
    }
    
    func getRules() -> Optional<Rules> {
        rulesLock.lock()
        guard let copy = rules else {
            return nil
        }
        rulesLock.unlock()
        
        return copy
    }
    
    private func checkDomain(_ query : Optional<String>) -> Outcome {
        guard let domain = query?.lowercased() else {
            return .allowed
        }
        
        guard let set = self.rules?.domains else {
            return .allowed
        }
        
        rulesLock.lock()
        for tld in set {
            if domain.hasSuffix(tld.indicator) {
                rulesLock.unlock()
                return .blocked
            }
        }
        rulesLock.unlock()
        
        return .allowed
    }
    
    private func checkHostname(_ query: Optional<String>) -> Outcome {
        guard let hostname = query?.lowercased() else {
            return .allowed
        }
        
        guard let set = self.rules?.hostnames else {
            return .allowed
        }
        
        rulesLock.lock()
        for actor in set {
            if hostname.contains(actor.indicator) {
                rulesLock.unlock()
                return .blocked
            }
        }
        rulesLock.unlock()
        
        
        return .allowed
    }
    
    func set(rules : Rules)  {
        rulesLock.lock()
        self.lastUpdate = NSDate().timeIntervalSince1970
        self.rules = rules
        rulesLock.unlock()
    }
    
    func decide(_ query: FirewallQuery) -> Outcome {
        if inDenial {
            logger.info("In denial, blocking connection");
            return .denyModeBlocked
        }
        
        if checkDomain(query.remoteURL) == .blocked {
            logger.info("Blocking connection based on domain rule");
            return .blocked
        }
        
        if checkHostname(query.remoteURL) == .blocked {
            logger.info("Denying connection based on hostname rule");
            return .blocked
        }
        
        if checkHostname(query.remoteSocket.address.description) == .blocked {
            logger.info("Denying connection based on hostname rule for IP");
            return .blocked
        }
        
        
        return .allowed
    }
    
}
