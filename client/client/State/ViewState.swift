//
//  CurrentConnections.swift
//  client
//
//  Created by Alex Lisle on 8/12/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import Logging

class ViewState : ObservableObject, EventListener {
    
    private let sort : (Connection, Connection) -> Bool = { (lhs, rhs) in
        switch lhs.startTimestamp.compare(rhs.startTimestamp) {
        case .orderedAscending: return false
        case .orderedDescending: return true
        case .orderedSame:
            switch lhs.remoteDisplayAddress.compare(rhs.remoteDisplayAddress) {
            case .orderedAscending : return true
            case .orderedDescending : return false
            case .orderedSame:
                return lhs.id.hashValue > rhs.id.hashValue
            }
        }
    }
    
    var objectWillChange = PassthroughSubject<Void, Never>()
    
    
    private var raw = Set<Connection>()
    private var lastSecond : Int = 0
    
    private(set) var connections: [FilterCategory: [Connection]] = [:]
    private(set) var lastConnections : [Connection] = []
    private(set) var amountsOverHour : [Int]
    
    
    private let logger : Logger

    var rules : Rules

    init() {
        var log  = Logger(label: "com.zerotrust.client.Models.ViewState")
        log.logLevel = .warning
        
        let jsonRules : JSONRules = Helpers.loadJSON("rules.json")
        self.rules = jsonRules.convert()
        self.amountsOverHour = (0..<60 * 10).map{ _ in 0 }
        self.lastSecond = Calendar.current.component(.second, from: Date())
        self.logger = log

        FilterCategory.allCases.forEach { category in self.connections[category] = [] }
        
        EventManager.shared.addListener(type: .ConnectionChanged, listener: self)
        
    }
    
    convenience init(aliveConnections: [Connection], deadConnections: [Connection])
    {
        self.init()
        
        self.connections.updateValue(aliveConnections, forKey: .latest)
        self.connections.updateValue(deadConnections, forKey: .five)
        
        if aliveConnections.count > 5 {
            self.lastConnections = Array(aliveConnections[0...5])
        } else {
            self.lastConnections = aliveConnections
        }
    }
    
    
    func updateLastSecond() -> Int {
        self.logger.info("updating the current time ticker")
        
        let date = Date()
        let minute = Calendar.current.component(.minute, from: date)
        let second = Calendar.current.component(.second, from: date)
        let currentTime = (minute * 10) + (second / 10)

        return currentTime
    }
    
    func updateTicks(currentTime: Int) -> [Int] {
        self.logger.info("updated ticks")
        
        var ticks : [Int] = self.amountsOverHour.map{ $0 }
        if self.lastSecond != currentTime {
            ticks[currentTime] = 0
        } else {
            ticks[currentTime] = ticks[currentTime] + 1
        }
        
        return ticks
    }
    
    func updateLast(_ categories : [FilterCategory: [Connection]]) -> [Connection] {
        var last : [Connection] = []
        self.logger.info("updating last connections")

        FilterCategory.allCases.forEach { last.append(contentsOf: categories[$0]!) }
        last.sort(by: sort)
        
        if last.count > 5 {
            last = Array(last[0..<5])
        }

        return last
    }
    
    
    func strip(_ array: [Connection]) -> [Connection] {
        var dups = Set<Int>()
        return array.filter {
            if dups.contains($0.dupeHash) {
                return false
            } else {
                dups.update(with: $0.dupeHash)
            }
            
            return true
        }
    }
    
    func updateCategories() -> [FilterCategory:[Connection]] {
        let now = Date()
        var cats : [FilterCategory : [Connection]] = [:]
        
        self.logger.info("resetting categories")
        FilterCategory.allCases.forEach { category in
            cats[category] = []
        }
        
        self.logger.info("iterating through connections")
        self.raw.forEach { connection in
            let mins =  now.minutes(from: connection.startTimestamp)
            
            FilterCategory.allCases.forEach{ category in
                let (lower, upper) = category.bounds
                
                if lower <= mins && upper > mins {
                    cats[category]!.append(connection)
                }
            }
        }
        
        self.logger.info("stripping dups")
        FilterCategory.allCases.forEach { cats[$0] = self.strip(cats[$0]!).map{ $0.clone() }.sorted(by: sort) }
        return cats
    }
    
    func eventTriggered(event: BaseEvent) {
        let event = event as! ConnectionChangedEvent
        self.logger.info("recieved conneciton changed event, updating view state")
        self.raw.update(with: event.connection)
        
        while self.raw.count > 1000 {
            self.raw.removeFirst()
        }
        

        let time = self.updateLastSecond()
        let ticks = self.updateTicks(currentTime: time)
        let cats = self.updateCategories()
        let last = self.updateLast(cats)
        
        DispatchQueue.main.async { [ weak self ] in
            guard let self = self else {
                return
            }
            self.objectWillChange.send()

            self.logger.info("assigning values")
            self.lastSecond = time
            self.amountsOverHour = ticks

            self.lastConnections = last
            self.connections = cats

        }
    }
 
    
}
