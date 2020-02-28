//
//  ProcessInfo.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 2/28/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation

public class ProcessInfo {
    public let pid : Int
    public let ppid: Int
    public let uid : Int?
    public let username : String?
    public let command : String?
    public let path : String?
    public let parent : ProcessInfo?
    public let bundle : Bundle?
    public let appBundle: Bundle?
    public let sha256 : String?
    public let md5 : String?
    
    public init(pid : Int,
                ppid: Int,
                uid : Int?,
                username : String?,
                command : String?,
                path : String?,
                parent : ProcessInfo?,
                bundle: Bundle?,
                appBundle: Bundle?,
                sha256: String?,
                md5: String?
                ) {
        self.pid = pid
        self.ppid = ppid
        self.uid = uid
        self.username = username
        self.command = command
        self.path = path
        self.parent = parent
        self.bundle = bundle
        self.appBundle = appBundle
        self.sha256 = sha256
        self.md5 = md5
    }

    
        
}

extension ProcessInfo : CustomStringConvertible {
    public var description: String  {
        return "PID:\(self.pid), PPID:\(self.ppid), USER: \(self.username ?? "unknown")(\(String(describing: self.uid))) - COMMAND: \(self.command ?? "unknown") - FP: \(self.path ?? "unknown")"
    }

}

extension ProcessInfo : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(pid)
        hasher.combine(ppid)
        hasher.combine(uid)
        hasher.combine(path)
    }
}


extension ProcessInfo : Equatable {
    public static func ==(lhs:ProcessInfo, rhs: ProcessInfo) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
