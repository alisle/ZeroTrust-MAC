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
    
    var objectWillChange = PassthroughSubject<Void, Never>()
    private var connections = Set<Connection>()
    
    private(set) var aliveConnections  : [Connection] = []
    private(set) var deadConnections : [Connection] = []
    
    var enabled = true
    var rules : Rules

    init() {
        let jsonRules : JSONRules = Helpers.loadJSON("rules.json")
        self.rules = jsonRules.convert()
    }
    
    convenience init(aliveConnections: [Connection], deadConnections: [Connection]) {
        self.init()
        self.aliveConnections = aliveConnections
        self.deadConnections = deadConnections
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
        
        var dups = Set<Int>()
        let alive = self.connections.filter{ $0.state != .disconnected && $0.state != .disconnecting }.map{ $0.clone() }.filter {
            if dups.contains($0.dupeHash) {
                return false
            } else {
                dups.update(with: $0.dupeHash)
            }
            
            return true
        }.sorted(by: sort)
        
        dups.removeAll()
        let dead = self.connections.filter{ $0.state == .disconnected || $0.state == .disconnecting }.map{ $0.clone() }.filter {
            if dups.contains($0.dupeHash) {
                return false
            } else {
                dups.update(with: $0.dupeHash)
            }
            
            return true
        }.sorted(by: sort)
        

        DispatchQueue.main.async() { [weak self] in
            guard let self = self else {
                return
            }

            
            print("CHANGING ARRAYS! \(connection.displayName) \(connection.remoteURL ?? "H/A") = \(connection.state)")
            self.aliveConnections = alive
            self.deadConnections = dead
            
            self.objectWillChange.send()
        }

    }
    
}
