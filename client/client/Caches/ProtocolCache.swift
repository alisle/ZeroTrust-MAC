//
//  ProtocolCache.swift
//  client
//
//  Created by Alex Lisle on 8/15/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


class ProtocolCache {
    static public let shared = ProtocolCache()
    private let Port2Protocol : [Int: PortProtocolDetails]
    
    init() {
        let protocols : [PortProtocolDetails] = Helpers.loadJSON("protocols.json")
        var map = [Int: PortProtocolDetails]()
        protocols.forEach {
            map[$0.port] = $0
        }
        
        Port2Protocol = map
    }
    
    
    func get(_ port : Int) -> Optional<PortProtocolDetails> {
        return Port2Protocol[port]
    }
    
        
}
