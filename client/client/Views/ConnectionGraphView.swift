//
//  ConnectionGraphView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/23/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI


struct ConnectionGraphView: View {
    
    let map : GeoMap
    init() {
        self.map = GeoMap.load()
    }
    
    private func drawSquare(centre: [CGFloat], side: CGFloat) -> Path {
        let path = Path { parent in
            parent.move(to:
                CGPoint.init(
                    x: centre[0] + side,
                    y: centre[1] + side
                )
            )
            parent.addLine( to:
                .init(
                    x: centre[0] + side,
                    y: centre[1] - side
                )
            )
            
            parent.addLine( to:
                .init(
                    x: centre[0] - side,
                    y: centre[1] - side
                )
            )
            
            parent.addLine( to:
                .init(
                    x: centre[0] - side,
                    y: centre[1] + side
                )
            )

            parent.addLine( to:
                .init(
                    x: centre[0] + side,
                    y: centre[1] + side
                )
            )

        }
        
        return path
    }
    
    private func createMap(size: CGSize) -> Path {
        let updated = GeoMap.normalize(map: self.map, size: size)

        let path = Path { parent in
            updated.features.forEach { feature in
                parent.addPath(drawSquare(centre: feature.centroid , side: feature.side))
                
            }
        }

        return path
    }
    
    
    var body: some View {
        let geometry = GeometryReader { geometry in
            self.createMap(size: geometry.size)
                .stroke(Color.white)
        }
        .frame(minWidth: 600, minHeight: 300)
        
        return geometry
    }
}

struct ConnectionGraphView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionGraphView()
    }
}
