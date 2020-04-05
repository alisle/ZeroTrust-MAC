//
//  ConnectionList.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/21/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
import Logging


class AllConnections : ObservableObject, EventListener {
    private let logger = Logger(label: "com.zerotrust.client.States.ConnectionList")
    private let map : Map = Map.shared
    private var shadowList : [UUID : Connection] = [:]
    @Published var connections : [Connection] = []

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
    
    init() {
        EventManager.shared.addListener(type: .ConnectionChanged, listener: self)
        self.updatePublishedValues()
    }

    private func updatePublishedValues() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)  { [ weak self ] in
            guard let self = self else {
                return
            }
            
            self.connections = self.shadowList.values.map{ $0.clone() }.sorted(by: self.sort)
            self.updatePublishedValues()
        }
    }
    
    func eventTriggered(event: BaseEvent) {
        let event = event as! ConnectionChangedEvent
        self.shadowList.updateValue(event.connection, forKey: event.connection.tag)
    }
}
