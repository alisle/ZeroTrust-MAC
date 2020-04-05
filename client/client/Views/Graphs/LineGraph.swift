//
//  LineGraph.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/9/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct NormalizedLineGraphSeries {
    private static let cubicCurveAlgorithm = CubicCurveAlgorithm()
    
    let series : [CGFloat]
    let points : [CGPoint]
    let controlPoints : [CubicCurveSegment]

    let max : CGFloat
    let min : CGFloat
    
    let size: CGSize
    let scale : CGSize
    
    
    init(_ min: CGFloat, _ max: CGFloat, _ series: [CGFloat], _ rect: CGRect) {
        
        var map : [CGFloat] = []
        
        series.enumerated().forEach{
            map.append($0.element)
            
            if series.count > $0.offset + 1 {
                let current = $0.element
                let next = $0.element
                let offset = (current > next) ? current - next : next - current
                
                map.append(current + (offset * 0.5))
            }
        }
        
        
        let size = CGSize(width: CGFloat(map.count - 1), height: max - min)
        let scale = CGSize(width: rect.size.width / size.width, height: rect.size.height / size.height)
        
        self.points = map.enumerated().map { CGPoint(x: CGFloat($0.offset) * scale.width, y: rect.size.height - ($0.element * scale.height)) }
        
        self.controlPoints = NormalizedLineGraphSeries.cubicCurveAlgorithm.controlPointsFromPoints(dataPoints: points)
        
        self.max = max
        self.min = min
        self.scale = scale
        self.size = size
        self.series = series
    }
    
    
}


struct LineGraph: View {
    let series : [CGFloat]
    
    var body: some View {
        ZStack {
            GridPath(x: 50.0, y: 10.0)
                .stroke(Color.gray, lineWidth: 1)
            
            LinePath(series: self.series)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(
                                colors: [
                                    .red,
                                    .yellow,
                                    .green,
                                    .blue,
                                    .purple,
                                    .red
                            ]),
                            center: .center
                        ),
                        lineWidth: 2
                )
        }.padding(10)
    }
}

struct GridPath: Shape {
    private static let max : CGFloat = 20
    let x : CGFloat
    let y: CGFloat
    
    init(x : CGFloat, y: CGFloat) {
        self.x = x
        self.y = (y > GridPath.max) ? GridPath.max : y
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let xStep = rect.size.width / x
        let yStep = rect.size.height / y
        
        path.addRect(rect)
                
        (0..<Int(x)).forEach {
            path.move(to: .init(x: xStep * CGFloat($0), y: rect.minY))
            path.addLine(to: .init(x: xStep * CGFloat($0), y: rect.maxY))
        }
        
        (0..<Int(y)).forEach {
            path.move(to: .init(x: rect.minX, y: yStep * CGFloat($0)))
            path.addLine(to: .init(x: rect.maxX, y: yStep * CGFloat($0)))
        }
        
        return path
    }
}

struct LinePath: Shape {
    var series : [CGFloat] = [
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0
    ]
    
    var animatableData :
        AnimatablePair<CGFloat,
        AnimatablePair<CGFloat,
        AnimatablePair<CGFloat,
        AnimatablePair<CGFloat,
        AnimatablePair<CGFloat,
        AnimatablePair<CGFloat,
        AnimatablePair<CGFloat,
        AnimatablePair<CGFloat,
        AnimatablePair<CGFloat,
        CGFloat>>>>>>>>> {
        
        get {
            var copy = series
            (copy.count..<10).forEach { _ in copy.append(0) }
            
            return AnimatablePair(
                copy[0], AnimatablePair(
                copy[1], AnimatablePair(
                copy[2], AnimatablePair(
                copy[3], AnimatablePair(
                copy[4], AnimatablePair(
                copy[5], AnimatablePair(
                copy[6], AnimatablePair(
                copy[7], AnimatablePair(
                copy[8], copy[9]
            )))))))))
        }
        set {
            series[0] = newValue.first
            series[1] = newValue.second.first
            series[2] = newValue.second.second.first
            series[3] = newValue.second.second.second.first
            series[4] = newValue.second.second.second.second.first
            series[5] = newValue.second.second.second.second.second.first
            series[6] = newValue.second.second.second.second.second.second.first
            series[7] = newValue.second.second.second.second.second.second.second.first
            series[8] = newValue.second.second.second.second.second.second.second.second.first
            series[9] = newValue.second.second.second.second.second.second.second.second.second
        }
    }
 
    private func box(_ point : CGPoint, _ rect: CGRect) -> CGPoint {
        var point = point
        
        if point.x < rect.minX {
            point.x = rect.minX
        } else if point.x > rect.maxX {
            point.x = rect.maxX
        }
        
        if point.y < rect.minY {
            point.y = rect.minY
        } else if point.y > rect.maxY {
            point.y = rect.maxY
        }
        
        return point
    }
    
    
    func path(in rect: CGRect) -> Path {
        let normalized = NormalizedLineGraphSeries(0, 100, series, rect)
        var path = Path()
        
        (0..<normalized.points.count).forEach {
            let point = self.box(normalized.points[$0], rect)
            
            
            if $0 == 0 {
                path.move(to: point)
            } else {
                let firstControlPoint = self.box(normalized.controlPoints[$0 - 1].firstControlPoint, rect)

                path.addQuadCurve(to: point, control: firstControlPoint)
            }
        }

        
        return path
    }
}

struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        let capacity = 10
        let min : CGFloat = 0.0
        let max : CGFloat = 100.0
        
        let floats = (0..<capacity).map { _ in CGFloat.random(in: min...max) }
        
        let view = LineGraph(series: floats)
            .frame(width: 540, height: 200, alignment: .center)
        
        return view
    }
}
