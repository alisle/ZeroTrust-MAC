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

class FirewallEvent {
    let EventType : FirewallEventType
    
    init(type : FirewallEventType) {
        self.EventType = type
    }
}


class FirewallConnectionOut : FirewallEvent {
    let pid : pid_t;
    let ppid : pid_t;
    
    init(pid: pid_t, ppid: pid_t) {
        self.pid = pid;
        self.ppid = ppid;
        
        super.init(type: FirewallEventType.outboundConnection)
    }
}
