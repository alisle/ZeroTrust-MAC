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
    let geomap : GeoMap = GeoMap.load()
    var objectWillChange = PassthroughSubject<Void, Never>()
    private var connections = Set<Connection>()
    var lastSecond : Int = 0
    
    private(set) var lastConnections : [Connection] = []
    private(set) var aliveConnections  : [Connection] = []
    private(set) var deadConnections : [Connection] = []
    private(set) var counts : [GeoCountry] = []
    private(set) var amountsOverHour : [Int]
    
    var enabled = true
    var rules : Rules

    init() {
        let jsonRules : JSONRules = Helpers.loadJSON("rules.json")
        self.rules = jsonRules.convert()
        self.amountsOverHour = (0..<60 * 10).map{ _ in 0 }
        self.lastSecond = Calendar.current.component(.second, from: Date())
    }
    
    convenience init(aliveConnections: [Connection], deadConnections: [Connection])
    {
        self.init()
        self.aliveConnections = aliveConnections
        self.deadConnections = deadConnections
        if self.aliveConnections.count > 5 {
            self.lastConnections = Array(self.aliveConnections[0...5])
        } else {
            self.lastConnections = Array(self.aliveConnections[0...self.aliveConnections.count])
        }
    }
    
    func connectionChanged(_ connection: Connection) {
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

        self.connections.update(with: connection)
        
        self.counts = []
        self.connections.forEach {
            if let iso = $0.country {
                if let country = geomap.iso[iso] {
                    self.counts.append(country)
                }
            }
        }
        
        var dups = Set<Int>()
        let alive = self.connections.filter {
                $0.state != .disconnected &&
                $0.state != .disconnecting &&
                $0.state != .closed
        }.map{ $0.clone() }.filter {
            if dups.contains($0.dupeHash) {
                return false
            } else {
                dups.update(with: $0.dupeHash)
            }
            
            return true
        }.sorted(by: sort)
        
        dups.removeAll()
        let dead = self.connections.filter {
                $0.state == .disconnected ||
                $0.state == .disconnecting ||
                $0.state == .closed
        }.map{ $0.clone() }.filter {
            if dups.contains($0.dupeHash) {
                return false
            } else {
                dups.update(with: $0.dupeHash)
            }
            
            return true
        }.sorted(by: sort)
        
        var last = Array(alive)
        last.append(contentsOf: dead)
        last.sort(by: sort)
        
        if last.count > 5 {
            last = Array(last[0..<5])
        }
        
        let date = Date()
        let minute = Calendar.current.component(.minute, from: date)
        let second = Calendar.current.component(.second, from: date)
        let currentTime = (minute * 10) + (second / 10)
        
        var ticks : [Int] = self.amountsOverHour.map{ $0 }
        if self.lastSecond != currentTime {
            ticks[currentTime] = 0
        } else {
            ticks[currentTime] = ticks[currentTime] + 1
        }

        
        DispatchQueue.main.async() { [weak self] in
            guard let self = self else {
                return
            }

            
            self.amountsOverHour = ticks
            self.lastSecond = currentTime
            self.aliveConnections = alive
            self.deadConnections = dead
            self.lastConnections = last
            
            self.objectWillChange.send()
        }

    }
    
}
