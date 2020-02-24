//
//  SocketAddressTests.swift
//  ZeroTrust FWTests
//
//  Created by Alex Lisle on 2/19/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import XCTest

@testable import ZeroTrust_FW

class SocketAddressTests : XCTestCase {
    func testInit() {
        let address = IPAddress("192.168.0.1")!
        let socket = SocketAddress(address: address, port: 90)
        
        XCTAssertEqual(socket.address, address)
        XCTAssertEqual(socket.port, 90)
        
        XCTAssertEqual("192.168.0.1:90", socket.description)
    }

    func testSockAddrInit() {
        var addr : sockaddr_in = sockaddr_in()
        addr.sin_addr = in_addr(s_addr: UInt32(3232235521).bigEndian)
        addr.sin_port = UInt16(90).bigEndian
        
        let socket = SocketAddress(addr)
        XCTAssertEqual(socket.address.description, "192.168.0.1")
        XCTAssertEqual(socket.port, 90)
        XCTAssertEqual("192.168.0.1:90", socket.description)

    }

    func testHashEquals() {
        let address = IPAddress("192.168.0.1")!
        let first = SocketAddress(address: address, port: 90)
        let second = SocketAddress(address: address, port: 90)

        XCTAssertEqual(first.hashValue, second.hashValue)
    }

    func testHashNotEqualsIP() {
        let address = IPAddress("192.168.0.1")!
        let address2 = IPAddress("192.168.0.2")!
        
        let first = SocketAddress(address: address, port: 90)
        let second = SocketAddress(address: address2, port: 90)

        XCTAssertNotEqual(first.hashValue, second.hashValue)
    }

    func testHashNotEqualsPort() {
        let address = IPAddress("192.168.0.1")!
        let first = SocketAddress(address: address, port: 100)
        let second = SocketAddress(address: address, port: 90)

        XCTAssertNotEqual(first.hashValue, second.hashValue)

    }

    func testEquals() {
        let address = IPAddress("192.168.0.1")!
        let first = SocketAddress(address: address, port: 90)
        let second = SocketAddress(address: address, port: 90)

        XCTAssertTrue(first == second)
    }
    
    func testNotEqualsPort() {
        let address = IPAddress("192.168.0.1")!
        let first = SocketAddress(address: address, port: 90)
        let second = SocketAddress(address: address, port: 100)

        XCTAssertTrue(first != second)
    }

    func testNotEqualsAddress() {
        
        let address = IPAddress("192.168.0.1")!
        let address2 = IPAddress("192.168.0.2")!
        
        let first = SocketAddress(address: address, port: 90)
        let second = SocketAddress(address: address2, port: 90)

        XCTAssertTrue(first != second)

    }

}
