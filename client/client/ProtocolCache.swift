//
//  ProtocolCache.swift
//  client
//
//  Created by Alex Lisle on 8/15/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


class ProtocolCache {
    private let Port2Protocol : [Int: Protocol]
    
    init() {
        let protocols : [Protocol] = Helpers.loadJSON("protocols.json")
        var map = [Int: Protocol]()
        protocols.forEach {
            map[$0.port] = $0
        }
        
        Port2Protocol = map
    }
    
    
    func get(port : Int) -> Optional<Protocol> {
        return Port2Protocol[port]
    }
    
        
}
