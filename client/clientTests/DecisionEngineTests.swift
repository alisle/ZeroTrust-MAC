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
    func generateQuery() -> FirewallQuery {
        let info = ProcessDetails(
            pid : 1,
            ppid: 0,
            uid : nil,
            username : nil,
            command : nil,
            path : nil,
            parent : nil,
            bundle: nil,
            appBundle: nil,
            sha256: nil,
            md5: nil,
            peers: []
        )

        return FirewallQuery(
            tag: UUID(),
            id: 1,
            timestamp: 2.0,
            version: .InboundTCPV4,
            remoteSocket: SocketAddress(address: IPAddress("192.168.1.23")!, port: 99),
            localSocket: SocketAddress(address: IPAddress("127.0.0.1")!,  port: 102),
            process : info
            )
    }
    
    private func generateRulesEntry(indicator: String)  -> RulesEntry {
        return RulesEntry(indicator: indicator, meta_id: "id")
    }
    
    func testDomainDeny() {
        let rules = Rules(domains: [ generateRulesEntry(indicator: "newguy.badguy.com") ], hostnames: [], metadata: [:])
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
