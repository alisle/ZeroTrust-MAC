//
//  Helpers.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

class Helpers {
    static private var maxArgumentSize = Helpers.getSysCtlMaxArgumentSize()
    /*
    static func getIPString(address: inout UInt32) -> String? {
        let length = Int(INET_ADDRSTRLEN) + 2
        var buffer : Array<CChar> = Array(repeating: 0, count: length)
        let hostCString = inet_ntop(AF_INET, &address, &buffer, socklen_t(length))
        return String.init(cString: hostCString!)
    }
    
    */
    
    
    static func getHostInformation(sockaddr : inout sockaddr_in) -> (host: IPAddress, port: Int)? {
        let address = IPAddress(sockaddr.sin_addr)
        let port = Int(UInt16(sockaddr.sin_port).byteSwapped)
        return (address, port)
    }
    
    static private func getSysCtlMaxArgumentSize() -> size_t {
        var mib = [ CTL_KERN, KERN_ARGMAX, 0 ]
        var size : size_t = 0
        var argmsize : size_t = MemoryLayout<size_t>.size
        
        sysctl(&mib, 2, &size, &argmsize, nil, 0)
        
        return size
    }
    
    static func getUsernameFromUID(uid: Optional<uid_t>) -> Optional<String> {
        guard let id = uid else {
            return Optional.none
        }
        
        guard let passwd = getpwuid(id) else {
            return Optional.none
        }
        
        return String(cString: passwd.pointee.pw_name)
    }
    
    
    static func getUIDForPID(pid: pid_t) -> Optional<uid_t> {
        var procInfo = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib = [ CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        sysctl(&mib, 4, &procInfo, &size, nil, 0)
        
        return procInfo.kp_eproc.e_ucred.cr_uid
    }
    
    static func getPidPath(pid: pid_t) -> Optional<String> {
        guard pid > 1 else {
            return Optional.none
        }
        
        var mib = [ CTL_KERN, KERN_PROCARGS2, pid ]
        var buffer : Array<CChar> = Array(repeating: 0, count: maxArgumentSize)
        var size : size_t = maxArgumentSize
        
        guard sysctl(&mib, 3, &buffer, &size, nil, 0) == 0 else {
            guard let buffer = get_process_name(pid) else {
                return Optional.none
            }            
            defer {
                buffer.deallocate()
            }
            
            let path = String(cString: buffer)
            return Optional(path)
            
        }
        
        let path = Array(buffer.dropFirst(MemoryLayout<UInt32>.size))
        let pathString = String(cString: path)
        
        return Optional<String>(pathString)
    }
    
    static func getBinaryAppBundle(fullBinaryPath : Optional<String>) -> Optional<Bundle> {
        guard var path = fullBinaryPath else {
            return Optional.none
        }
        
        var bundle : Optional<Bundle> = Bundle(path: path)
        while !path.isEqual("/") && !path.isEqual("") && bundle == nil {
            let index  = path.lastIndex(of: "/") ?? path.startIndex
            let substring = path[..<index]
            bundle = Bundle(path: String(substring))
            path = String(substring)
        }
        
        return bundle
    }
    
    static func getTopLevelAppBundle(fullBinaryPath: Optional<String>) -> Optional<Bundle> {
        guard fullBinaryPath != nil else {
            return Optional.none
        }
        
        if let range = fullBinaryPath!.range(of: ".app") {
            let substring = fullBinaryPath![..<range.upperBound]
            return getBinaryAppBundle(fullBinaryPath: String(substring))
        }
        
        return Optional<Bundle>.none
    }
    
    
    // Copied from the SwiftUI demo code.
    static func loadJSON<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
        let data: Data
        
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
            else {
                fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        return loadJSON(data)
    }
    
    
    static func loadJSON<T: Decodable>(_ data: Data, as type: T.Type = T.self) -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse to json: \(error)")
        }
    }
}
