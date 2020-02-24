//
//  SocketAddress.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 2/18/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation

public struct SocketAddress {
    public let address : IPAddress
    public let port : Int

    public init(address : IPAddress, port: Int)  {
        self.address = address
        self.port = port
    }
    
    public init(_ sockaddr: sockaddr_in) {
        self.address = IPAddress(sockaddr.sin_addr)
        self.port = Int(UInt16(sockaddr.sin_port).byteSwapped)
    }
    
}

extension SocketAddress : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.address)
        hasher.combine(self.port)
    }
}

extension SocketAddress : Equatable {
     public static func ==(lhs: SocketAddress, rhs: SocketAddress) -> Bool {
        if lhs.port == rhs.port && lhs.address == rhs.address {
            return true
        }
        
        return false
     }
}

extension SocketAddress : CustomStringConvertible {
    public var description: String  {
        return "\(self.address):\(self.port)"
    }
}