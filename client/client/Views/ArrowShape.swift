//
//  ArrowShape.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 12/10/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        let arrow = CGMutablePath()
        arrow.addArrow(
            start: .init(x: rect.minX, y: rect.midY),
            end:  .init(x: rect.maxX, y: rect.midY),
            pointerLineLength: rect.width / 8,
            arrowAngle: CGFloat(Double.pi / 4)
        )
        
        
        return Path(arrow)
    }
}

struct ArrowView: View {
    var body: some View {
        ZStack {
            ArrowShape()
                .stroke(style:
                    StrokeStyle(
                        lineWidth: 5.0,
                        lineCap: CGLineCap.round,
                        lineJoin: CGLineJoin.round
                ))
                .fill(Color.white)
                .padding()

        }
    }

}
struct ArrowShape_Previews: PreviewProvider {
    static var previews: some View {
        let view = ArrowView()
            .frame(width: 600, height: 300, alignment: .center)
                
        return view
    }
}
