//
//  ConnectionColouredGraphView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 11/2/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionColouredGraphView: View {
    @EnvironmentObject var viewState : ViewState

    private func drawSquare(centre: [CGFloat], side: CGFloat, size: CGSize) -> Path {
        var max = size.width
        if size.height < max {
            max = size.height
        }
        
        let path = Path { parent in
            parent.move(to:
                CGPoint.init(
                    x: (centre[0] * size.width),
                    y: (centre[1] * size.height)
                )
            )
            
            parent.addRect(
                .init(
                    origin:
                        .init(
                            x:centre[0] * size.width,
                            y:centre[1] * size.height
                    ),
                    size: .init(
                        width: side * max / 2,
                        height: side * max / 2
                    )
                )
            )
            
        }
        return path
    }
    
    private func createMap(size: CGSize) -> Path {
        let path = Path { parent in
            viewState.geomap.features.forEach { feature in
                parent.addPath(drawSquare(centre: feature.centroid , side: feature.side, size: CGSize( width: size.width - 10, height: size.height - 10)))
            }
        }
        return path
    }
    
    private func background(size: CGSize) -> some View {
        Path { parent in
                self.viewState.geomap.features.forEach { feature in
                    parent.addPath(
                        self.drawSquare(
                            centre: feature.centroid,
                            side: feature.side,
                            size: CGSize(
                                width: size.width - 10,
                                height: size.height - 10
                            )
                        )
                    )
                }
        }.fill(Color.black)
    }
    
    
    private func convert(connections: [Connection]) -> [GeoCountry] {
        var countries : [GeoCountry] = []
        connections.forEach { connection in
            if let iso = connection.country {
                if let country = self.viewState.geomap.iso[iso] {
                    countries.append(country)
                }
            }
        }
        
        return countries
    }
    
    var body: some View {
        let geometry = GeometryReader { geometry in
            ZStack {
                self.background(size: geometry.size)
                ForEach(self.convert(connections: self.viewState.aliveConnections)) { feature in
                    self.drawSquare(
                        centre: feature.centroid,
                        side: feature.side,
                        size: CGSize(
                            width: geometry.size.width - 10,
                            height: geometry.size.height - 10
                        )
                    ).fill(Color.white)
                }
            }.drawingGroup()
        }
        .frame(minWidth: 600, minHeight: 300)
        
        return geometry
    }
}

struct ConnectionColouredGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let viewState = ViewState()
        viewState.connectionChanged( generateTestConnection(direction: ConnectionDirection.outbound))
        
        return ConnectionColouredGraphView().environmentObject(viewState)
        
    }
}
