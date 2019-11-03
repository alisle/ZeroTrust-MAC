//
//  GeoMap.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/23/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

/*
 {
     "area": 14440.772691897295,
     "centroid": [
         612.8656343507567,
         53.258968798068
     ],
     "properties": {
         "admin": "Russia"
     },
     "side": 120.16976613065907,
     "type": "Feature"
 },
 */


struct GeoCountry: Codable, Identifiable {
    var area : CGFloat
    var centroid: [CGFloat]
    var properties: GeoCountryProperties
    var side: CGFloat
    var type: String
    
    var id: String {
        get { self.properties.name }
    }
}

struct GeoCountryProperties: Codable {
    var name: String
    var iso: String
}

struct GeoMap: Codable {
    var features : [GeoCountry]
    var iso : [String: GeoCountry]

    static func load() -> GeoMap {
        var iso : [String: GeoCountry] = [:]
        var features : [GeoCountry] = Helpers.loadJSON("area.json")
        let (min, max, side) = findLimits(features: features)
        let stretch = CGSize(width: max.x - min.x, height: max.y - min.y)
        let scale = CGSize(width: 1.0 / stretch.width, height: 1.0 / stretch.height)
        let sideScale = 1.0 / side
        
        for feature in 0 ..< features.count {
            features[feature].centroid[0] = (features[feature].centroid[0] - min.x) * scale.width
            features[feature].centroid[1] = (features[feature].centroid[1] - min.y) * scale.height
            features[feature].side = features[feature].side * sideScale
            
            iso[features[feature].properties.iso] = features[feature]
        }
        
        return GeoMap(features: features, iso: iso)
     }
    
    private static func findLimits(features : [GeoCountry]) -> (CGPoint, CGPoint, CGFloat) {
        var min = CGPoint(x: 1000, y: 1000)
        var max = CGPoint(x: 0, y: 0)
        var side = CGFloat.leastNormalMagnitude
        
        features.forEach {
            let maxX = $0.centroid[0] + $0.side
            let maxY = $0.centroid[1] + $0.side

            let minX = $0.centroid[0]// - $0.side
            let minY = $0.centroid[1]// - $0.side
        
            if minX < min.x {
                min.x = minX
            }
            
            if maxX > max.x {
                max.x = maxX
            }
            
            if maxY > max.y {
                max.y = maxY
            }
            
            if minY < min.y {
                min.y = minY
            }
            
            if $0.side > side {
                side = $0.side
            }
        }
        
        return (min, max, side)
    }

}

