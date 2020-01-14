//
//  GlobeShape.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 11/11/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct GlobeCentre : Shape {
    let countries : [GraphCountry]
    
    func path(in rect: CGRect) -> Path {
        var world = Path()
        
        countries.forEach { country in
            let point = CGPoint(
                x: country.centroid.x * rect.maxX,
                y: country.centroid.y * rect.maxY
            )
            
            let size = CGSize(width: 10, height: 10)
            let rect = CGRect(origin: point, size: size)
            
            world.addRect(rect)
        }
        
        return world
    }
    
}
struct GlobeGraph : Shape {
    let countries : [GraphCountry]
    func path(in rect: CGRect) -> Path {
        var world = Path()
        
        countries.forEach { country in
            country.paths.forEach { paths in
                let path = paths[0].map( { point in
                    CGPoint(x: point.x * rect.maxX, y: point.y * rect.maxY)
                })
                
                world.addLines(path)
            }
        }

        return world
    }
    
    
}

struct GlobeShape_Previews: PreviewProvider {
    static var previews: some View {
        let graph = Graph.load()
        
        let view = ZStack {
            GlobeGraph(countries: graph.countries)
                .fill(Color.blue)
            
            GlobeCentre(countries: graph.countries)
                .fill(Color.red)
            
            GlobeGraph(countries: graph.countries)
                .stroke(Color.white)
        }
        .frame(width: 1200, height: 800, alignment: .center)
        
        
        return view
    }
}
