//
//  ConnectionAmountShape.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 11/13/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionAmountShape: Shape {
    let counts:  [Int]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scale = rect.height / 50
        let step : CGFloat = rect.width / CGFloat(counts.count)
        
        for x in 0..<counts.count {
            path.move(to:
                CGPoint(
                    x: step * CGFloat(x),
                    y: CGFloat(counts[x]) * scale)
            )

            path.addEllipse(in:
                CGRect(
                    x: step * CGFloat(x),
                    y: CGFloat(counts[x]) * scale,
                    width: step,
                    height: step
                )
            )
            
        }
        
        return path
    }
}

struct ConnectionAmountShape_Previews: PreviewProvider {
    static var previews: some View {
        let total = 60 * 6
        let counts =  (0..<total).map { _ in Int.random(in: 0...50) }
           
        let view = VStack {
            ConnectionAmountShape(counts: counts)
                .fill(Color.white)
        }.frame(width: 600, height: 300, alignment: .center)
        
        
        return view
    }
}
