//
//  ProcessInfo.swift
//  ZeroTrust FWTests
//
//  Created by Alex Lisle on 2/19/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
import CommonCrypto

class ProcessInfo {
    public let pid : Int
    public let ppid: Int
    public let pgid : Int
    public let uid : Int
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
                pgid : Int,
                uid : Int,
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
        self.pgid = pgid
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
        return "PID:\(self.pid), PPID:\(self.ppid), PGID:\(self.pgid), USER: \(self.username ?? "unknown")(\(self.uid)) - COMMAND: \(self.command ?? "unknown") - FP: \(self.path ?? "unknown")"
    }

}

extension ProcessInfo : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(pid)
        hasher.combine(ppid)
        hasher.combine(pgid)
        hasher.combine(uid)
        hasher.combine(path)
    }
}


extension ProcessInfo : Equatable {
    public static func ==(lhs:ProcessInfo, rhs: ProcessInfo) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

class Processes {
    static private var maxArgumentSize : size_t = {
        var mib = [ CTL_KERN, KERN_ARGMAX, 0 ]
        var size : size_t = 0
        var argmsize : size_t = MemoryLayout<size_t>.size
        
        sysctl(&mib, 2, &size, &argmsize, nil, 0)
        
        return size
    }()
    
    func process(_ pid: pid_t) -> ProcessInfo? {
        guard var kinfo =  getKinfo(pid: pid) else {
            return nil
        }

        let ppid = Int(kinfo.kp_eproc.e_ppid)
        let pgid = Int(kinfo.kp_eproc.e_pgid)
        let uid = Int(kinfo.kp_eproc.e_ucred.cr_uid)
        let username = getUsername(uid: kinfo.kp_eproc.e_ucred.cr_uid)
        
        var command = getProcessName(pid: pid)
        if command == nil {
            command =  withUnsafePointer(to: &kinfo.kp_proc.p_comm) {
                       String(cString: UnsafeRawPointer($0).assumingMemoryBound(to: CChar.self))
                   }
        }
        
        
        let sha256 = Processes.generateSHA256(path: command)
        let md5 = Processes.generateMD5(path: command)
        
        
        let path = getProcessPath(pid: pid)
        let pid = Int(pid)
        
        
        let parent = (ppid != 0) ? self.process(kinfo.kp_eproc.e_ppid) : nil
        let bundle = self.getBundle(path: path)
        let appbundle = self.getAppBundle(path: path)
        
        return ProcessInfo(pid: pid,
                           ppid: ppid,
                           pgid: pgid,
                           uid: uid,
                           username: username,
                           command: command,
                           path: path,
                           parent: parent,
                           bundle: bundle,
                           appBundle: appbundle,
                           sha256: sha256,
                           md5: md5
        )
    }
    
    private func getKinfo(pid: pid_t) -> kinfo_proc? {
        var kinfo = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib = [ CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        
        guard sysctl(&mib, 4, &kinfo, &size, nil, 0) == 0 else {
            return nil
        }

        return kinfo
    }
    
    private func getUsername(uid: uid_t) -> String? {
        guard let userinfo = getpwuid(UInt32(uid)) else {
            return Optional.none
        }
        
        return String(cString: userinfo.pointee.pw_name)
    }
    
    private func getProcessPath(pid: pid_t) -> String? {
        guard let buffer = get_proc_path(pid) else {
            return nil
        }
        defer {
            buffer.deallocate()
        }
        
        let path = String(cString: buffer)
        return path
    }
    
    private func getProcessName(pid: pid_t) -> String? {
        guard let buffer = get_process_name(pid) else {
            return nil
        }
        defer {
            buffer.deallocate()
        }
        
        let path = String(cString: buffer)
        return path
        
    }
    
    private func getBundle(path: String?) -> Bundle? {
        guard var path = path else {
            return nil
        }
        
        print("starting with \(path)")
        var bundle = Bundle(path: path)
        while !path.isEqual("/") && !path.isEqual("") && bundle == nil {
            let index = path.lastIndex(of: "/") ?? path.startIndex
            let substring = path[..<index]
            path = String(substring)
            bundle = Bundle(path: path)
        }
        
        print("found bundle with \(path)")
        
        return bundle
    }
    
    private func getAppBundle(path: String?) -> Bundle? {
        guard var path = path else {
            return nil
        }
        
        guard let range = path.range(of: ".app", options: .backwards) else {
            return nil
        }
        
        path = String(path[..<range.upperBound])
        print("This is my path \(path)")
        return getBundle(path: path)
    }

    public static func generateSHA256(path: String?) -> String? {
        guard let path = path else {
            return nil
        }
        
        let bufferSize = 1024 * 1024
        guard let file = FileHandle(forReadingAtPath: path) else {
            return nil
        }
        defer {
            file.closeFile()
        }

        var context = CC_SHA256_CTX()
        CC_SHA256_Init(&context)

        while autoreleasepool(invoking: {
            let data = file.readData(ofLength: bufferSize)
            if data.count > 0 {
                data.withUnsafeBytes {
                    _ = CC_SHA256_Update(&context, $0, numericCast(data.count))
                }
                return true
            } else {
                return false
            }
        }) { }

        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        digest.withUnsafeMutableBytes {
            _ = CC_SHA256_Final($0, &context)
        }
                
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    public static func generateMD5(path: String?) -> String? {
        guard let path = path else {
            return nil
        }

        let bufferSize = 1024 * 1024
        guard let file = FileHandle(forReadingAtPath: path) else {
            return nil
        }
        defer {
            file.closeFile()
        }

        var context = CC_MD5_CTX()
        CC_MD5_Init(&context)
        
        while autoreleasepool(invoking: {
            let data = file.readData(ofLength: bufferSize)
            if data.count > 0 {
                data.withUnsafeBytes {
                    _ = CC_MD5_Update(&context, $0, numericCast(data.count))
                }
                return true
            } else {
                return false
            }
        }) { }

        var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        digest.withUnsafeMutableBytes {
            _ = CC_MD5_Final($0, &context)
        }
            
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
