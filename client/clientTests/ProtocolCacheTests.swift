//
//  ProtocolCacheTests.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/1/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//


import XCTest
@testable import ZeroTrust_FW

class ProtocolCacheTests : XCTestCase {
    func testGetHit() {
        let cache = ProtocolCache()
        XCTAssertNotNil(cache.get(443))
    }
    
    func testGetMiss() {
        let cache = ProtocolCache()
        XCTAssertNil(cache.get(-12))
    }
}
