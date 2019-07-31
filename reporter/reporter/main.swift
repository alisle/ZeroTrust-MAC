//
//  main.swift
//  reporter
//
//  Created by Alex Lisle on 6/8/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


class ConsumerThread : Thread {
    private var consumer = FirewallEventConsumer()
    convenience init(connectionState : CurrentConnections) {
        self.init()
        consumer = FirewallEventConsumer(state : connectionState)
    }
    
    override func main() {
        if consumer.open() {
            consumer.process()
        }
    }
}

var state = CurrentConnections()
let thread = ConsumerThread(connectionState: state)

thread.start()

while(!thread.isCancelled) {
    print("Connections:")
    state.dump()
    sleep(5)
}
