//
//  ListenEndedEvent.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/11/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
public class ListenEndedEvent : BaseEvent {
    let listen : SocketListen
    
    init(listen: SocketListen) {
        self.listen = listen
        super.init(.ListenEnded)
    }
}
