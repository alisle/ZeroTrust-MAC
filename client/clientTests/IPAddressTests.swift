//
//  IPAddressTests.swift
//  ZeroTrust FWTests
//
//  Created by Alex Lisle on 2/18/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import XCTest

@testable import ZeroTrust_FW

class IPAddressTests : XCTestCase {
    func testIPv4InAddr() {
        var addr = in_addr()
        XCTAssertEqual(inet_pton(AF_INET, "192.168.0.1", &addr), 1)
        let address = IPAddress(addr)
        
        XCTAssertEqual(address.family, .IPv4)
        switch(address.address) {
        case .IPv6(_): XCTAssertFalse(true)
        case (let .IPv4(value)):
            XCTAssertEqual(addr.s_addr, value.s_addr)
        }
        
        XCTAssertEqual(address.representation, "192.168.0.1")
    }
    
    func testIPv6InAddr() {
        var addr = in6_addr()
        XCTAssertEqual(inet_pton(AF_INET6, "2001:db8:85a3:20:310:8a2e:370:7334", &addr), 1)
        
        let address = IPAddress(addr)
        
        XCTAssertEqual(address.family, .IPv6)
        switch(address.address) {
        case .IPv4(_): XCTAssertFalse(true)
        default: ()
        }
        
        XCTAssertEqual(address.representation, "2001:db8:85a3:20:310:8a2e:370:7334")
    }
    
    func testNetworkByteOrder() {
        let ip = UInt32(3232235521).bigEndian
        let address = IPAddress(UInt32NetworkByeOrder: ip)
        
        XCTAssertEqual(address.representation, "192.168.0.1")
    }
    
    func testStringAddrIPv4() {
        let address = IPAddress("192.168.0.1")!
        XCTAssertEqual("192.168.0.1", address.representation)
    }

    func testStringAddrIPv6() {
        let address = IPAddress("2001:db8:85a3:20:310:8a2e:370:7334")!
        XCTAssertEqual("2001:db8:85a3:20:310:8a2e:370:7334", address.representation)
    }

    
    func testStringInvalid() {
        let address = IPAddress("I am not a real string")
        XCTAssertNil(address)
    }

    
    func testNotLocalHost() {
        let address = IPAddress("192.168.0.1")
        XCTAssertFalse(address!.localhost)
    }

    func testIsLocalHost() {
        let address = IPAddress("127.0.0.1")
        XCTAssertTrue(address!.localhost)
    }

    func testHashSame() {
        let first = IPAddress("192.168.0.1")!
        let second = IPAddress("192.168.0.1")!

        XCTAssertEqual(first.hashValue, second.hashValue)
    }
    
    func testHashDifferent() {
        let first = IPAddress("192.168.0.1")!
        let second = IPAddress("192.168.0.2")!

        XCTAssertNotEqual(first.hashValue, second.hashValue)
    }

    func testEqualsIPv4() {
        let first = IPAddress("192.168.0.1")!
        let second = IPAddress("192.168.0.1")!

        XCTAssertTrue(first == second)
    }
    
    func testNotEqualsIPv4() {
        let first = IPAddress("192.168.0.1")!
        let second = IPAddress("192.168.0.2")!
        
        XCTAssertFalse(first == second)
    }

}



