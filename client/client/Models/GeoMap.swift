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


struct GeoCountry: Codable {
    var area : CGFloat
    var centroid: [CGFloat]
    var properties: GeoCountryProperties
    var side: CGFloat
    var type: String
}

struct GeoCountryProperties: Codable {
    var admin: String
}

struct GeoMap: Codable {
    var features : [GeoCountry]
    var max : CGPoint
    
    static func load() -> GeoMap {
        var features : [GeoCountry] = Helpers.loadJSON("area.json")
        var (min, max) = findLimits(features: features)
        
        for feature in 0 ..< features.count {
            features[feature].centroid[0] = features[feature].centroid[0] - min.x
            features[feature].centroid[1] = features[feature].centroid[1] - min.y
        }
        
        max.x = max.x - min.x
        max.y = max.y - min.y
        
        return GeoMap(features: features, max: max)
     }
    
    private static func findLimits(features : [GeoCountry]) -> (CGPoint, CGPoint) {
        var min = CGPoint(x: 1000, y: 1000)
        var max = CGPoint(x: 0, y: 0)
        
        features.forEach {
            let maxX = $0.centroid[0]
            let maxY = $0.centroid[1]

            let minX = $0.centroid[0]
            let minY = $0.centroid[1]
        
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
        }
        
        return (min, max)
    }
    
    
    static func normalize(map: GeoMap, size: CGSize) -> GeoMap {
        let scale = CGSize(width: size.width / map.max.x, height: size.height / map.max.y)
        
        var updated = map
        for index in 0 ..< updated.features.count {
            
            let x = updated.features[index].centroid[0] * scale.width
            let y = updated.features[index].centroid[1] * scale.height
                        
            updated.features[index].centroid[0] = x
            updated.features[index].centroid[1] = y
            
            updated.features[index].side = updated.features[index].side * scale.height
        }
        
        return updated
    }
}

