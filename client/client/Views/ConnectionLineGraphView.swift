//
//  ConnectionLineGraphView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 11/2/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionLineGraphView: View {
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
    
    
    var body: some View {
        let geometry = GeometryReader { geometry in
            self.createMap(size: geometry.size)
                .stroke(Color.white)
        }
        .frame(minWidth: 600, minHeight: 300)
        
        return geometry
    }
    
}

struct ConnectionLineGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let viewState = ViewState()
        return ConnectionLineGraphView().environmentObject(viewState)
    }
}
