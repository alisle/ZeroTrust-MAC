//
//  OutboundConnectionCountView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/11/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct Indicator: View {
    let max: CGFloat
    var count: CGFloat

    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(Color.clear)
                .frame(width: geometry.size.width - 10, height: geometry.size.width - 10)
                .modifier(CountIndicator(max: self.max, count: self.count))
                .animation(.easeInOut(duration: 0.5))

        }
    }
}

struct CountIndicator: AnimatableModifier {
    let max : CGFloat
    var count: CGFloat = 0
    
    var animatableData: CGFloat {
        get { count }
        set { count = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(ArcShape(max: 1, count: 1).foregroundColor(.gray))
            .overlay(ArcShape(max: max, count: count).foregroundColor(.red))
            .overlay(LabelView(max: max, count: count))
    }
    
    struct ArcShape: Shape {
        let max : CGFloat
        let count: CGFloat
        
        func percentage() -> CGFloat {
            if count > max {
                return 1.0
            } else {
                return (1 / max) * count
            }
        }
        
        func path(in rect: CGRect) -> Path {

            var p = Path()
            p.addArc(center: CGPoint(x: rect.width / 2.0, y:rect.height / 2.0),
                     radius: rect.height / 2.0 + 5.0,
                     startAngle: .degrees(0),
                     endAngle: .degrees(360.0 * Double(percentage())), clockwise: false)

            return p.strokedPath(.init(lineWidth: 6, dash: [6, 3], dashPhase: 10))
        }
    }
    
    struct LabelView: View {
        let max : CGFloat
        let count: CGFloat
        
        func box() -> String {
            if count > max{
                return "\(Int(max))+"
            } else {
                return "\(Int(count))"
            }
        }
        
        var body: some View {
            Text(box())
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .animation(nil)
        }
    }
}

struct ConnectionCountView : View {
    let max : CGFloat
    var count: CGFloat = 0
    
    var animatableData: CGFloat {
        get { count }
        set { count = newValue }
    }

    var body: some View {
        ZStack {
            Color
                .clear
                .overlay(Indicator(max: self.max, count: self.count))
        }
    }
}

struct OutboundConnectionCountView_Previews: PreviewProvider {
    static var previews: some View {
        return ConnectionCountView(max: 30, count: 10)
    }
}
