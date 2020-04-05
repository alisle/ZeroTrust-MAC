//
//  IPAddress.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 2/18/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
import Logging

public class IPAddress {
    private let logger = Logger(label: "com.zerotrust.client.Models.IPAddress")

    public enum Family {
        case IPv4, IPv6
    }
    
    public enum Address : Hashable, Equatable {
        
        case IPv4(in_addr), IPv6(in6_addr)
        
        public static func ==(lhs: IPAddress.Address, rhs: IPAddress.Address) -> Bool {
            switch(lhs, rhs) {
            case (let .IPv4(lhsAddr), let .IPv4(rhsAddr)):
                if lhsAddr.s_addr == rhsAddr.s_addr {
                    return true
                } else {
                    return false
                }
                
            default:
                return false
            }
        }
        
        public func hash(into hasher: inout Hasher) {
            switch self {
            case (let .IPv4(addr)):
                hasher.combine(4)
                hasher.combine(addr.s_addr)
            case (var .IPv6(addr)):
                withUnsafeBytes(of: &addr) {
                    hasher.combine(bytes: $0)
                }
            }
        }
    }
    
    public let family : Family
    public let address : Address
    
    public lazy var localhost : Bool = {
        switch(self.address) {
        case (let .IPv4(addr)):
            if addr.s_addr.bigEndian == 2130706433 {
                return true
            }
            
            return false
        default:
            return false
        }
    }()
    
    
    public lazy var representation : String = { [unowned self] in
        switch address {
        case .IPv4(var addr):
            self.logger.debug("getting IPv4 representation")
            
            let length = Int(INET_ADDRSTRLEN) + 2
            var buffer : Array<CChar> = Array(repeating: 0, count: length)
            guard let hostCString = inet_ntop(AF_INET, &addr, &buffer, socklen_t(length)) else {
                self.logger.warning("unable to get address!")
                return "Unknown"
            }
            
            return String.init(cString: hostCString)
            
        case .IPv6(var addr):
            self.logger.debug("getting IPv6 representation")

            let length = Int(INET6_ADDRSTRLEN) + 2
            var buffer : Array<CChar> = Array(repeating: 0, count: length)
            
            guard let hostCString = inet_ntop(AF_INET6, &addr, &buffer, socklen_t(length)) else {
                self.logger.warning("unable to get address!")
                return "Unknown"
            }

            return String.init(cString: hostCString)
        }
    }()
    
    
    public init(_ in_addr: in_addr) {
        self.family = .IPv4
        self.address = .IPv4(in_addr)
    }
    
    public init(_ in6_addr: in6_addr) {
        self.family = .IPv6
        self.address = .IPv6(in6_addr)
    }
    
    public convenience init(UInt32NetworkByeOrder: UInt32) {
        let addr = in_addr(s_addr: UInt32NetworkByeOrder)
        self.init(addr)
    }

    public convenience init?(_ address:  String) {
        var addr = in_addr()
        if inet_pton(AF_INET, address, &addr) == 1 {
            self.init(addr)
            self.representation = address
            
        } else {
            var addr6 = in6_addr()
            if inet_pton(AF_INET6, address, &addr6) == 1 {
                self.init(addr6)
                self.representation = address
            } else {
                return nil
            }
        }
    }
    
     
}

extension IPAddress : CustomStringConvertible {
    public var description: String  {
        return self.representation
    }
}

extension IPAddress : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.family)
        hasher.combine(self.address)
    }
}

extension IPAddress : Equatable {
     public static func ==(lhs: IPAddress, rhs: IPAddress) -> Bool {
        return lhs.address == rhs.address
     }
}
