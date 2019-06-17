//
//  FirewallEvent.swift
//  reporter
//
//  Created by Alex Lisle on 6/17/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

enum FirewallEventType : Int {
    case outboundConnection = 0,
         inboundConnection,
         connectionUpdate
}

enum FirewallUpdateType: Int {
    case connecting = 1,
    connected,
    disconnecting,
    disconnected,
    closing,
    bound
}

class FirewallEvent {
    let EventType : FirewallEventType
    let tag : UUID
    
    init(type : FirewallEventType, tag : UUID) {
        self.EventType = type
        self.tag = tag
    }
    
    func dump() {
        print("-------------- \(EventType) --------------")
        print("Tag: \(tag)")
    }
}

class FirewallConnectionUpdate : FirewallEvent {
    let update : FirewallUpdateType
    init(tag: UUID, update: FirewallUpdateType) {
        self.update = update;
        super.init(type: FirewallEventType.connectionUpdate, tag: tag)
    }
    
    override func dump() {
        super.dump()
        print("Update Type: \(update)")
    }
}

class FirewallConnectionOut : FirewallEvent {
    let pid : pid_t
    let ppid : pid_t
    let uid : Optional<uid_t>
    let user : Optional<String>
    let remoteAddress : String
    let localAddress : String
    let localPort : Int
    let remotePort : Int
    let process : Optional<String>
    let parentProcess : Optional<String>
    let parentBundle : Optional<Bundle>
    let processBundle : Optional<Bundle>
    let parentTopLevelBundle : Optional<Bundle>
    let processTopLevelBundle: Optional<Bundle>

    var displayName : String = ""
    
    init(tag: UUID,
         pid: pid_t,
         ppid: pid_t,
         remoteAddress : String,
         localAddress : String,
         remotePort: Int,
         localPort: Int
        ) {
        self.pid = pid
        self.ppid = ppid
        self.localPort = localPort
        self.localAddress = localAddress
        self.remotePort = remotePort
        self.remoteAddress = remoteAddress
        
        self.process = Helpers.getPidPath(pid: pid)
        self.parentProcess = Helpers.getPidPath(pid: ppid)
        
        self.parentBundle = Helpers.getBinaryAppBundle(fullBinaryPath: parentProcess)
        self.processBundle = Helpers.getBinaryAppBundle(fullBinaryPath: process)
        
        self.parentTopLevelBundle = Helpers.getTopLevelAppBundle(fullBinaryPath: parentProcess)
        
        self.processTopLevelBundle = Helpers.getTopLevelAppBundle(fullBinaryPath: process)
        self.uid = Helpers.getUIDForPID(pid: pid)
        self.user = Helpers.getUsernameFromUID(uid: uid)
                
        super.init(type: FirewallEventType.outboundConnection, tag: tag)
        displayName = createDisplayName()
        
    }
    
    private func createDisplayName()  -> String {
        if processBundle?.displayName != nil {
            return processBundle!.displayName!
        }
        
        if parentBundle?.displayName != nil {
            return parentBundle!.displayName!
        }
        
        if processTopLevelBundle?.displayName != nil {
            return processTopLevelBundle!.displayName!
        }
        
        if parentTopLevelBundle?.displayName != nil {
            return parentTopLevelBundle!.displayName!
        }
        
        if process != nil {
            let lastIndex = process?.lastIndex(of: "/")
            let substring = String(process!.substring(from: lastIndex!).dropFirst())
            return substring
        }
        
        if parentProcess != nil {
            let lastIndex = parentProcess?.lastIndex(of: "/")
            let substring = String(parentProcess!.substring(from: lastIndex!).dropFirst())
            return substring
        }
        
        
        return "unknown"
    }
    
    override func dump() {
        super.dump()
        print("PID: \(pid)")
        print("PPID: \(ppid)")
        print("App Name: \(displayName)")
        print("Local Address: \(localAddress)")
        print("Local Port: \(localPort)")
        
        if(self.uid != nil) {
            print("UID: \(self.uid)")
        }
        
        if(self.user != nil) {
            print("Username: \(self.user)")
        }
        
        if(self.process != nil) {
            print("Local Process: \(self.process!)")
        }
        
        if self.parentProcess != nil {
            print("Local Parent Process: \(self.parentProcess!)")
        }
        
        if self.processBundle != nil {
            print("Local Bundle Name: \(self.processBundle!.displayName)")
        }
        
        if self.parentBundle != nil {
            print("Local Parent Bundle Name: \(self.parentBundle!.displayName)")
        }
        
        if self.processTopLevelBundle != nil {
            print("Local Top Level Bundle Name: \(self.processTopLevelBundle!.displayName)")
        }
        
        if self.parentTopLevelBundle != nil {
            print("Local Top Level Parent Bundle Name: \(self.parentTopLevelBundle!.displayName)")
        }
        
        
        print("Remote Address: \(remoteAddress)")
        print("Remote port: \(remotePort)")
        //print("--------------------------------------------")
        print("")
        
    }
}
