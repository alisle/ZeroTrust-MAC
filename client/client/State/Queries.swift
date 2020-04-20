//
//  Queries.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/9/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
import Logging

class Queries : ObservableObject, EventListener {
    private let logger = Logger(label: "com.zerotrust.client.States.Queries")
    
    private var shadowMadeDecisions : [(FirewallQuery, Outcome)] = []
    private var shadowPendingQueries : Set<FirewallQuery> = Set()
    private var shadowNeedsInput : Set<FirewallQuery> = Set()
    
    @Published var pendingQueries : Set<FirewallQuery> = Set()
    @Published var maadeDecisions : [(FirewallQuery, Outcome)] = []
    @Published var needsInput : Set<FirewallQuery> = Set()
    
    init() {
        EventManager.shared.addListener(type: .DecisionQuery, listener: self)
        EventManager.shared.addListener(type: .DecisionMade, listener: self)
        EventManager.shared.addListener(type: .DecisionNeedsInput, listener: self)
        
        self.updatePublishedValues()
    }
    
    private func updatePublishedValues() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)  { [ weak self ] in
            guard let self = self else {
                return
            }
            
            self.pendingQueries = self.shadowPendingQueries
            self.needsInput = self.shadowNeedsInput
            
            var array = self.shadowMadeDecisions.sorted(by: { lhs, rhs in return lhs.0.timestamp > rhs.0.timestamp })
            if array.count > 100 {
                array = Array(array[array.startIndex..<array.startIndex + 100])
            }

            self.maadeDecisions = array
            self.updatePublishedValues()
        }
    }
    
    func eventTriggered(event: BaseEvent) {
        switch(event.type) {
        case .DecisionMade:
            let event = event as! DecisionMadeEvent
            shadowPendingQueries.remove(event.query)
            shadowNeedsInput.remove(event.query)
            shadowMadeDecisions.append((event.query, event.decision))
            
        case .DecisionQuery:
            let event = event as! DecisionQueryEvent
            shadowPendingQueries.update(with: event.query)
            
        case .DecisionNeedsInput:
            let event = event as! DecisionNeedsInputEvent
            shadowNeedsInput.update(with: event.query)
            
        default: return
        }
    }
}
