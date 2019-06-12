//
//  main.swift
//  reporter
//
//  Created by Alex Lisle on 6/8/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

while(true) {
    var connection : io_connect_t = 0;
    let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("com_notrust_firewall_driver"))
    
    if service != 0 {
        print("Found service");
        let status = IOServiceOpen(service, mach_task_self_, 0, &connection)
        if status == kIOReturnSuccess {
            print("Service has been opened")
            var output : UInt64 = 0;
            var outputCount : UInt32 = 1;
            let status = IOConnectCallScalarMethod(connection, 0, nil, 0, &output, &outputCount)
            
            if status == kIOReturnSuccess {
                print("Got return of \(output)")
            } else {
                print("Failed to call test function \(status)")
            }
            
            print("Closing Connection")
            IOServiceClose(connection)
        }
        
        IOObjectRelease(service)
    } else {
        print("Unable to get service")
    }

    print("sleeping")
    sleep(3)
}


let events = KernEvents()
print("Listening for firewall events");

while(true) {
    guard let event = events.get() else {
        print("invalid event, skipping");
        continue
    }
    
    event.dump()
}
