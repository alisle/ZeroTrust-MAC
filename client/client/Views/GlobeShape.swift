//
//  GlobeShape.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 11/11/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct GlobeShape : Shape {
    let map : [GeoCountry]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let sideMax = (rect.size.width > rect.size.height) ? rect.size.width / 6 : rect.size.height / 6
        
        
        self.map.forEach { feature in
            let origin = CGPoint(
                x: feature.centroid[0] * rect.maxX,
                y: feature.centroid[1] * rect.maxY
            )
            
            var size = CGSize(
                width: feature.side * sideMax,
                height: feature.side * sideMax
            )
            
            if size.width + origin.x > rect.width {
                size.width = (rect.width - origin.x) - 10
            }
            
            if size.height + origin.y > rect.height {
                size.height = (rect.height - origin.y) - 10
            }
            
            if size.width != size.height {
                size.width = size.height
            }
            
            path.addRect(
                .init(origin: origin, size: size)
            )
        }
        
        return path
    }

}

struct GlobeShape_Previews: PreviewProvider {
    static var previews: some View {
        let map = GeoMap.load()
            
        let view = VStack {
            GlobeShape(map: map.features)
                .fill(Color.red)
        }.frame(width: 600, height: 300, alignment: .center)
        
        
        return view
    }
}
