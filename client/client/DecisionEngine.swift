//
//  DecisionEngine.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 9/10/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import Logging

enum Decision : CaseIterable {
    case Allow
    case Deny
    case Unknown
    
    func toInt() -> UInt32 {
        switch self {
        case .Allow: return 0
        case .Deny: return 1
        case .Unknown: return 2
        }
    }
}


class DecisionEngine {
    let logger = Logger(label: "com.zerotrust.client.DecisionEngine")

    private var rules : Optional<Rules> = nil
    private let rulesLock = NSLock()
    private var lastUpdate = NSDate().timeIntervalSince1970
    
    func getRules() -> Optional<Rules> {
        rulesLock.lock()
        guard let copy = rules else {
            return nil
        }
        rulesLock.unlock()
        
        return copy
    }
    
    private func checkDomain(_ query : Optional<String>) -> Decision {
        guard let domain = query?.lowercased() else {
            return Decision.Allow
        }
        
        guard let set = self.rules?.domains else {
            return Decision.Allow
        }
        
        rulesLock.lock()
        for tld in set {
            if domain.hasSuffix(tld.indicator) {
                rulesLock.unlock()
                return Decision.Deny
            }
        }
        rulesLock.unlock()
        
        return Decision.Allow
    }
    
    private func checkHostname(_ query: Optional<String>) -> Decision {
        guard let hostname = query?.lowercased() else {
            return Decision.Allow
        }
        
        guard let set = self.rules?.hostnames else {
            return Decision.Allow
        }
        
        rulesLock.lock()
        for actor in set {
            if hostname.contains(actor.indicator) {
                rulesLock.unlock()
                return Decision.Deny
            }
        }
        rulesLock.unlock()
        
        
        return Decision.Allow
    }
    
    func set(rules : Rules)  {
        rulesLock.lock()
        self.lastUpdate = NSDate().timeIntervalSince1970
        self.rules = rules
        rulesLock.unlock()
    }
    
    func decide(_ query: FirewallQuery) -> Decision {
        
        if checkDomain(query.remoteURL) == Decision.Deny {
            logger.info("Denying connection based on domain rule");
            return Decision.Deny
        }
        
        if checkHostname(query.remoteURL) == Decision.Deny {
            logger.info("Denying connection based on hostname rule");
            return Decision.Deny
        }
        
        if checkHostname(query.remoteAddress.description) == Decision.Deny {
            logger.info("Denying connection based on hostname rule for IP");
            return Decision.Deny
        }
        
        
        return Decision.Allow
    }
    
}
