//
//  main.swift
//  reporter
//
//  Created by Alex Lisle on 6/8/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

let comm = KernComm()

if comm.open() != true {
    print("Unable to open communication with driver!")
    exit(1)
}

defer {
    comm.disable()
    comm.close()
}

if comm.enable() != true {
    print("Unable to enable firewall")
    exit(1)
}

if comm.createNotificationPort() != true {
    print("Unable to enable notification port")
    exit(1)
}

defer {
    comm.destroyNotificationPort()
}

print("Starting the loop")
while(true) {
    
    if !comm.hasData() {
        print("No data waiting")
        if !comm.waitForData() {
            print("Something went wrong")
        }
    }

    guard let event = comm.dequeue() else {
        print("problem getting event")
        continue
    }
    
    event.dump()
}

/*
let events = KernEvents()
print("Listening for firewall events");

while(true) {
    guard let event = events.get() else {
        print("invalid event, skipping");
        continue
    }
    
    event.dump()
}
*/

