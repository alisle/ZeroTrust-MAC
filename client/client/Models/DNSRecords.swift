//
//  DNSARecord.swift
//  client
//
//  Created by Alex Lisle on 7/29/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

public struct ARecord {
    let url : String
    let ip: IPAddress
    
    init(url: String, ip: IPAddress) {
        self.url = url
        self.ip = ip
    }
}

public struct CNameRecord {
    let url: String
    let cName: String
    
    init(url: String, cName: String) {
        self.url = url
        self.cName = cName
    }
}
