//
//  AllListens.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/13/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
import Logging


class AllListens : ObservableObject, EventListener {
    private let logger = Logger(label: "com.zerotrust.client.States.AllListeners")
    private var shadowList = Set<SocketListen>()
    @Published var listens : [SocketListen] = []

    init() {
        EventManager.shared.addListener(type: .ListenStarted, listener: self)
        EventManager.shared.addListener(type: .ListenEnded, listener: self)
        self.updatePublishedValues()
    }

    private func updatePublishedValues() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)  { [ weak self ] in
            guard let self = self else {
                return
            }
                
            self.listens = Array(self.shadowList)
            self.updatePublishedValues()
        }
    }

    
    func eventTriggered(event: BaseEvent) {
        switch(event.type) {
        case .ListenStarted:
            let event = event as! ListenStartedEvent
            shadowList.update(with: event.listen)
            
        case .ListenEnded:
            let event = event as! ListenEndedEvent
            shadowList.remove(event.listen)
            
        default: return
        }
        
    }
    
    
        
    
}
