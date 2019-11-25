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

class ViewState : ObservableObject, StateListener {
    let sort : (Connection, Connection) -> Bool = { (lhs, rhs) in
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

    let geomap : GeoMap = GeoMap.load()
    var objectWillChange = PassthroughSubject<Void, Never>()
    private var raw = Set<Connection>()
    var lastSecond : Int = 0
    
    private(set) var connections: [Category: [Connection]] = [:]
    private(set) var lastConnections : [Connection] = []
    private(set) var counts : [GeoCountry] = []
    private(set) var amountsOverHour : [Int]
    
    var enabled = true
    var rules : Rules

    init() {
        let jsonRules : JSONRules = Helpers.loadJSON("rules.json")
        self.rules = jsonRules.convert()
        self.amountsOverHour = (0..<60 * 10).map{ _ in 0 }
        self.lastSecond = Calendar.current.component(.second, from: Date())
        
        Category.allCases.forEach { category in self.connections[category] = [] }
    }
    
    convenience init(aliveConnections: [Connection], deadConnections: [Connection])
    {
        self.init()
        
        self.connections[.latest] = aliveConnections
        self.connections[.five] = deadConnections
        
        if aliveConnections.count > 5 {
            self.lastConnections = Array(aliveConnections[0...5])
        } else {
            self.lastConnections = aliveConnections
        }
    }
    
    func updateCounts() -> [GeoCountry] {
        var counts : [GeoCountry] = []
        self.raw.forEach {
            if let iso = $0.country {
                if let country = geomap.iso[iso] {
                    counts.append(country)
                }
            }
        }

        return counts
    }
    
    func updateLastSecond() -> Int {
        let date = Date()
        let minute = Calendar.current.component(.minute, from: date)
        let second = Calendar.current.component(.second, from: date)
        let currentTime = (minute * 10) + (second / 10)

        return currentTime
    }
    
    func updateTicks(currentTime: Int) -> [Int] {
        var ticks : [Int] = self.amountsOverHour.map{ $0 }
        if self.lastSecond != currentTime {
            ticks[currentTime] = 0
        } else {
            ticks[currentTime] = ticks[currentTime] + 1
        }
        
        return ticks
    }
    
    func updateLast(_ categories : [Category: [Connection]]) -> [Connection] {
        var last : [Connection] = []
        
        Category.allCases.forEach { last.append(contentsOf: categories[$0]!) }
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
    
    func updateCategories() -> [Category:[Connection]] {
        let now = Date()
        var cats : [Category : [Connection]] = [:]
        
        Category.allCases.forEach { category in
            cats[category] = []
        }
        
        self.raw.forEach { connection in
            let mins =  now.minutes(from: connection.startTimestamp)
            
            Category.allCases.forEach{ category in
                let (lower, upper) = category.bounds
                
                if lower <= mins && upper > mins {
                    cats[category]!.append(connection)
                }
            }
        }
        
        Category.allCases.forEach { cats[$0] = self.strip(cats[$0]!).sorted(by: sort) }
        return cats
    }
    
    func connectionChanged(_ connection: Connection) {

        self.raw.update(with: connection)
        let counts = self.updateCounts()
        let time = self.updateLastSecond()
        let ticks = self.updateTicks(currentTime: time)
        let cats = self.updateCategories()
        let last = self.updateLast(cats)
        
        DispatchQueue.main.async() { [weak self] in
            guard let self = self else {
                return
            }

            self.counts = counts
            self.amountsOverHour = ticks
            self.lastSecond = time
            self.lastConnections = last
            self.connections = cats
            
            self.objectWillChange.send()
        }

    }
    
}
