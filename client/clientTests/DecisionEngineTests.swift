//
//  DecisionEngineTests.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 9/26/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import XCTest
@testable import ZeroTrust_FW

class DecisionEngineTests : XCTestCase {
    private func generateQuery() -> FirewallQuery {
        
        return FirewallQuery(
            tag: UUID(),
            id: 1,
            timestamp: 2.0,
            pid: 1,
            ppid: 0,
            remoteAddress: "192.168.1.23",
            localAddress: "127.0.0.1",
            remotePort: 99,
            localPort: 102,
            procName: "phony_mc_lonely"
        )
        
    }
    
    private func generateRulesEntry(indicator: String)  -> RulesEntry {
        return RulesEntry(indicator: indicator, meta_id: "id")
    }
    
    func testDomainDeny() {
        let rules = Rules(domains: [ generateRulesEntry(indicator: "newgay.badguy.com") ], hostnames: [], metadata: [:])
        let engine = DecisionEngine()
        engine.set(rules: rules)
        
        let query = generateQuery()
        query.remoteURL = "newguy.badguy.com"
        
        
        let decision = engine.decide(query)
        
        XCTAssertEqual(decision, Decision.Deny)
    }
    
    func testDomainAllow() {
        let rules = Rules(domains: [ generateRulesEntry(indicator: "badguy.com") ], hostnames: [], metadata: [:])
        let engine = DecisionEngine()
        engine.set(rules: rules)
        
        let query = generateQuery()
        query.remoteURL = "not.thebad.guy.com"
        
        let decision = engine.decide(query)
        XCTAssertEqual(decision, Decision.Allow)
    }
    
    func testHostnameIPDeny() {
        let rules = Rules(domains: [], hostnames: [ generateRulesEntry(indicator: "192.168.1.23") ], metadata: [:])
            let engine = DecisionEngine()
            engine.set(rules: rules)
            
            let query = generateQuery()
            let decision = engine.decide(query)
            XCTAssertEqual(decision, Decision.Deny)
    }
    
    func testHostnameURLDeny() {
        let rules = Rules(domains: [], hostnames: [ generateRulesEntry(indicator: "i.am.the.bad.guy.com") ], metadata: [:])
        let engine = DecisionEngine()
        engine.set(rules: rules)
        
        let query = generateQuery()
        query.remoteURL = "i.am.the.bad.guy.com"
        
        let decision = engine.decide(query)
        XCTAssertEqual(decision, Decision.Deny)
    }
    
    func testHostnameURLAllow() {
        let rules = Rules(domains: [], hostnames: [ generateRulesEntry(indicator: "i.am.the.bad.guy.com") ], metadata: [:])
        let engine = DecisionEngine()
        engine.set(rules: rules)
        
        let query = generateQuery()
        query.remoteURL = "i.am.the.not.a.bad.guy.com"
        
        let decision = engine.decide(query)
        XCTAssertEqual(decision, Decision.Allow)
    }
                
}
