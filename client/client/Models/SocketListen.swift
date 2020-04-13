//
//  SocketListen.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/13/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation

class SocketListen : FirewallEvent {
    let timestamp : Date
    let process : ProcessDetails
    let localSocket : SocketAddress
    
    init(tag: UUID,
         timestamp: TimeInterval,
         localSocket: SocketAddress,
         process: ProcessDetails
        ) {
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.localSocket = localSocket
        self.process = process
        
        super.init(type: .socketListener, tag: tag)
    }
}

extension SocketListen : Equatable {
    public static func ==(lhs: SocketListen, rhs: SocketListen) -> Bool {
        return lhs.tag == rhs.tag
    }
}

extension SocketListen : Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.tag)
        hasher.combine(self.process)
        hasher.combine(self.localSocket)
    }
}
