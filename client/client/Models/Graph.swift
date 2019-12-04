//
//  GeoMap.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/23/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


struct Graph: Codable {
    let countries: [GraphCountry]
    let iso : [String: GraphCountry]

    static func load() -> Graph {
        let countries : [GraphCountry] = Helpers.loadJSON("transformed_countries.json")
        var iso : [String: GraphCountry] = [:]
        countries.forEach { country in
            iso[country.iso] = country
        }
        
        return Graph(countries: countries, iso: iso)
    }

}


struct GraphCountry: Codable, Identifiable {
    var area: CGFloat
    var centroid: CGPoint
    var name: String
    var paths: [[[CGPoint]]]
    var iso: String
    
    var id: String {
        get { self.name }
    }
 
}
