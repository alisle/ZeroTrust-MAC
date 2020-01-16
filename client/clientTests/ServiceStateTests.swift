//
//  ServiceStateTests.swift
//  ZeroTrust FWTests
//
//  Created by Alex Lisle on 1/16/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import XCTest

@testable import ZeroTrust_FW

class TestListener : ServiceStateListener {
    var value : Bool
    
    init(_ value: Bool) {
        self.value = value
    }
    
    func serviceStateChanged(type: ServiceStateType, serviceEnabled: Bool) {
        print("\(type) has changed \(serviceEnabled)")
        value = serviceEnabled
    }
}


class ServiceStateTests : XCTestCase {
    func testEnableChange() {
        let state = ServiceState()
        XCTAssertTrue(state.enabled)
        
        state.enabled = false
        XCTAssertFalse(state.enabled)
    }
        
    func testInspectModeChange() {
        let state = ServiceState()
        XCTAssertFalse(state.inspectMode)
        
        state.inspectMode = true
        XCTAssertTrue(state.inspectMode)
        
        state.inspectMode = false
        XCTAssertFalse(state.inspectMode)

    }
        
    func testDenyModeChange() {
        let state = ServiceState()
        XCTAssertFalse(state.denyMode)
        
        state.denyMode = true
        XCTAssertTrue(state.denyMode)
        
        state.denyMode = false
        XCTAssertFalse(state.denyMode)

    }

    
    func testEnableChangeListener() {
        let state = ServiceState()
        let listener  = TestListener(true)
        
        state.addListener(type: .enabled, listener: listener)
        
        state.enabled = false
        XCTAssertFalse(listener.value)
        
        state.enabled = true
        XCTAssertTrue(listener.value)

    }
    
    
    func testInspectModeChangeListener() {
        let state = ServiceState()
        let listener  = TestListener(false)
        
        state.addListener(type: .inspectMode, listener: listener)

        state.inspectMode = true
        XCTAssertTrue(listener.value)

        state.inspectMode = false
        XCTAssertFalse(listener.value)

    }
    
    func testDenyModeChangeListener() {
        let state = ServiceState()
        let listener  = TestListener(false)
        
        state.addListener(type: .denyMode, listener: listener)
        
        state.denyMode = true
        XCTAssertTrue(listener.value)

        state.denyMode = false
        XCTAssertFalse(listener.value)

    }

}
