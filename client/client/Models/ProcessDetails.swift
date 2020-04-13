//
//  ProcessInfo.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 2/28/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
import SwiftUI

public class ProcessDetails {
    public let pid : Int
    public let ppid: Int
    public let uid : Int?
    public let username : String?
    public let command : String?
    public let path : String?
    public let parent : ProcessDetails?
    public let bundle : Bundle?
    public let appBundle: Bundle?
    public let sha256 : String?
    public let md5 : String?
    public let peers : [ProcessDetails]?
    public lazy var image : NSImage? = ProcessDetails.getImage(info: self)
    
    
    public var hasPeers : Bool {
        get {
            guard let count = self.peers?.count else {
                return false
            }
                        
            return count != 0
        }
    }
    
    private static func getImage(info: ProcessDetails) -> NSImage? {
        if let nsimage = info.bundle?.icon {
            return nsimage
        }
        
        if let nsimage = info.appBundle?.icon {
            return nsimage
        }
        
        if let nsimage = info.parent?.bundle?.icon {
            return nsimage
        }
        
        if let nsimage = info.parent?.appBundle?.icon {
            return nsimage
        }
        
        return nil
    }

    public init(pid : Int,
                ppid: Int,
                uid : Int?,
                username : String?,
                command : String?,
                path : String?,
                parent : ProcessDetails?,
                bundle: Bundle?,
                appBundle: Bundle?,
                sha256: String?,
                md5: String?,
                peers : [ProcessDetails]?
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
        self.peers = peers
    }
    
    public func updatedPeers(peers : [ProcessDetails]?) -> ProcessDetails {
        return ProcessDetails(
            pid: self.pid,
            ppid: self.ppid,
            uid: self.uid,
            username: self.username,
            command: self.command,
            path: self.path,
            parent: self.parent,
            bundle: self.bundle,
            appBundle: self.appBundle,
            sha256: self.sha256,
            md5: self.md5,
            peers: peers
        )
    }
    
    public func clone() -> ProcessDetails {
        return updatedPeers(peers: self.peers)
    }
}

extension ProcessDetails : CustomStringConvertible {
    public var description: String  {
        return "PID:\(self.pid), PPID:\(self.ppid), USER: \(self.username ?? "unknown")(\(String(describing: self.uid))) - COMMAND: \(self.command ?? "unknown") - FP: \(self.path ?? "unknown")"
    }
    
    public var shortDescription : String {
        return "PID:\(self.pid) - UID:\(self.uid ?? 0) - \(self.command ?? "unknown")"
    }

}

extension ProcessDetails : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(pid)
        hasher.combine(ppid)
        hasher.combine(uid)
        hasher.combine(path)
    }
}


extension ProcessDetails : Equatable {
    public static func ==(lhs:ProcessDetails, rhs: ProcessDetails) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension ProcessDetails : Identifiable {
    public var id: Int {
        get {
            return self.hashValue
        }
    }
}
