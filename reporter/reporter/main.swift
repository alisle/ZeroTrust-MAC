//
//  main.swift
//  reporter
//
//  Created by Alex Lisle on 6/8/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

let events = KernEvents()
print("Listening for firewall events");

while(true) {
    guard let event = events.get() else {
        print("invalid event, skipping");
        continue
    }
    
    event.dump()
}

