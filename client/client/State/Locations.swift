//
//  Locations.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/18/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation
import Logging

class Locations : ObservableObject, EventListener {
    private let logger = Logger(label: "com.zerotrust.client.States.Locations")
    private let map : Map = Map.shared
    private var shadowPoints : [UUID : MapPoint] = [:]
    
    @Published var points : [MapPoint] = []

    
    init() {
        EventManager.shared.addListener(type: .OpenedConnection, listener: self)
        EventManager.shared.addListener(type: .ClosedConnection, listener: self)
        self.updatePublishedValues()
    }
    
    private func updatePublishedValues() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)  { [ weak self ] in
            guard let self = self else {
                return
            }
            
            var points : Set<MapPoint> = []
            
            Array(self.shadowPoints.values).forEach {
                if points.contains($0) {
                    let point = MapPoint(
                        latitude: $0.latitude,
                        longitude: $0.longitude,
                        translated: $0.translated,
                        count: $0.count + 1
                    )
                    points.insert(point)
                } else {
                    points.insert($0)
                }
            }
                
            
            self.points = Array(points).sorted(by: { (lhs, rhs) -> Bool in
                return lhs.count > rhs.count
            })
            
            self.updatePublishedValues()
        }
    }


    func eventTriggered(event: BaseEvent) {
        switch event.type {
        case .OpenedConnection:
            let event = event as! OpenedConnectionEvent
            if let location = event.connection.location {
                guard let latitude = location.latitude else {
                    return
                }
                
                guard let longitude = location.longitude else {
                    return
                }
                
                let point = map.createPoint(latitude: Double(latitude), longitude: Double(longitude))
                self.shadowPoints.updateValue(point, forKey: event.connection.tag)
            }
        case .ClosedConnection:
            let event = event as! ClosedConnectionEvent
            self.shadowPoints.removeValue(forKey: event.connection.tag)

        default:
            return
        }
    }
}
