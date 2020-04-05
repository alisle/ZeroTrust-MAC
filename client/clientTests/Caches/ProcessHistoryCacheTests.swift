//
//  ProcessHistoryCacheTests.swift
//  ZeroTrust FWTests
//
//  Created by Alex Lisle on 3/30/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import XCTest
@testable import ZeroTrust_FW


class ProcessHistoryCacheTests : XCTestCase {
    func testSecondStep() {
        let cache = ProcessHistoryCache()
        (0...100).forEach { _ in
            let timeInterval = Date().timeIntervalSince1970 - TimeInterval.random(in: 0...(60 * 60))
            print("\(Date(timeIntervalSince1970: timeInterval))")
            
            let event = OpenedOutboundConnectionEvent(connection:
                Connection(
                    connection: TCPConnection(
                        tag: UUID(),
                        timestamp: timeInterval,
                        inbound: false,
                        process: generateProcessInfo(),
                        remoteSocket: SocketAddress(address: IPAddress("192.168.2.3")!, port: 80),
                        localSocket: SocketAddress(address: IPAddress("0.0.0.0")!, port: 80),
                        outcome: Outcome.allowed
                    ),
                    location: nil,
                    remoteURL: "wwww.google.com",
                    portProtocol: nil
                )
            )
            
            EventManager.shared.triggerEvent(event: event)
        }
        
        let array = cache.get(key: "012012", step: 1, duration: 60*60)
        
        XCTAssertNotNil(array)
        
    }

}
