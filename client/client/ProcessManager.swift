//
//  ProcessInfo.swift
//  ZeroTrust FWTests
//
//  Created by Alex Lisle on 2/19/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

// This code is based off https://github.com/beltex/SystemKit

import Foundation
import CommonCrypto
import Logging

struct ProcessWrapper {
    let process : ProcessDetails
    let timestamp = Date()
    
    var pid : Int {
        get {
            return self.process.pid
        }
    }
}

class ProcessManager {
    private let logger = Logger(label: "com.zerotrust.client.Models.Processes")
    var cache : [Int : ProcessWrapper] = [:]
        
    static private var maxArgumentSize : size_t = {
        var mib = [ CTL_KERN, KERN_ARGMAX, 0 ]
        var size : size_t = 0
        var argmsize : size_t = MemoryLayout<size_t>.size
        
        sysctl(&mib, 2, &size, &argmsize, nil, 0)
        
        return size
    }()
    
    func get(pid: pid_t) -> ProcessDetails? {
        let id = Int(pid)
        
        if let info = cache[id] {
            if info.timestamp.timeIntervalSinceNow < 5 * 60 {
                return info.process.clone()
            }
        }
        
        return process(pid)
    }
    
    
    func get(pid: pid_t, ppid: pid_t, command: String) -> ProcessDetails {
        let info = get(pid: pid) ?? self.process(pid: pid, ppid: ppid, command: command)
        return info.updatedPeers(peers: self.getChildren(pid: Int32(info.ppid)))
    }
    
    func getChildren(pid: pid_t) -> [ProcessDetails] {
        return self.listChildren(pid: pid).map{ self.get(pid: pid_t($0)) }.filter { $0 != nil }.map { $0! }
    }
    

    private func process(pid: pid_t, ppid: pid_t, command: String) -> ProcessDetails {
        guard let info = process(pid) else {
            let path = getProcessPath(pid: pid)
            let bundle = self.getBundle(path: path)
            let appbundle = self.getAppBundle(path: path)
            let sha256 = generateSHA256(path: path)
            let md5 = generateMD5(path: path)
            
            return ProcessDetails(
                pid: Int(pid),
                ppid: Int(ppid),
                uid: nil,
                username: nil,
                command: command,
                path: path,
                parent: process(ppid),
                bundle: bundle,
                appBundle: appbundle,
                sha256: sha256,
                md5: md5,
                peers: []
            )
        }
        
        return info
    }
    
    public func listChildren(pid: Int32) -> [Int32] {
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "pgrep -P \(pid)"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: String.Encoding.utf8) {
            let ppids = output.split(separator: "\n").map{ Int($0) }.filter{ $0 != nil }.map{ Int32($0!) }
            task.waitUntilExit()
            return ppids
        }
        
        task.waitUntilExit()
        return []
    }
    
    
    private func process(_ pid: pid_t) -> ProcessDetails? {
        guard var kinfo =  getKinfo(pid: pid) else {
            return nil
        }

        let ppid = Int(kinfo.kp_eproc.e_ppid)
        let uid = Int(kinfo.kp_eproc.e_ucred.cr_uid)
        let username = getUsername(uid: kinfo.kp_eproc.e_ucred.cr_uid)
        
        var command = getProcessName(pid: pid)
        if command == nil {
            command =  withUnsafePointer(to: &kinfo.kp_proc.p_comm) {
                       String(cString: UnsafeRawPointer($0).assumingMemoryBound(to: CChar.self))
                   }
        }
        
        let path = getProcessPath(pid: pid)
        let pid = Int(pid)
        let parent = (ppid != 0) ? self.process(kinfo.kp_eproc.e_ppid) : nil
        let bundle = self.getBundle(path: path)
        let appbundle = self.getAppBundle(path: path)
        
        let sha256 = generateSHA256(path: path)
        let md5 = generateMD5(path: path)

        //let children = getChildren(pid: Int32(pid))

        let info = ProcessDetails(pid: pid,
                           ppid: ppid,
                           uid: uid,
                           username: username,
                           command: command,
                           path: path,
                           parent: parent,
                           bundle: bundle,
                           appBundle: appbundle,
                           sha256: sha256,
                           md5: md5,
                           peers: []
            
        )
        
        self.cache[pid] = ProcessWrapper(process: info)
        return info
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
        
        logger.info("starting with \(path)")
        var bundle = Bundle(path: path)
        while !path.isEqual("/") && !path.isEqual("") && bundle == nil {
            let index = path.lastIndex(of: "/") ?? path.startIndex
            let substring = path[..<index]
            path = String(substring)
            bundle = Bundle(path: path)
        }
        
        logger.info("found bundle with \(path)")
        
        return bundle
    }
    
    func getAppBundle(path: String?) -> Bundle? {
        guard var path = path else {
            return nil
        }
        
        guard let range = path.range(of: ".app", options: .backwards) else {
            return nil
        }
        
        path = String(path[..<range.upperBound])
        logger.info("resolved path for app bundle: \(path)")
        return getBundle(path: path)
    }

    public func generateSHA256(path: String?) -> String? {
        logger.info("generating SHA256 for \(path ?? "None")")
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
    
    public func generateMD5(path: String?) -> String? {
        logger.info("generating MD5 for \(path ?? "None")")

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
