//
//  BarChart.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/1/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct BarChartCell : View {
    let size : CGSize
    let value : CGFloat
    let max : CGFloat

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                if (self.size.height / max) * value > 35 {
                    Text("\(Int(value))")
                        .font(.caption)
                        .bold()
                        .rotationEffect(.degrees(-90))
                        .offset(y: 35)
                        .zIndex(1)
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(Color.init(.sRGBLinear, red: 0.1, green: 0.01, blue: 0.1, opacity: 1.0))
                        .frame(width: self.size.width, height: (self.size.height / max) * value, alignment: .center)
                    
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
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
                                center: .center))
                        .frame(width: self.size.width, height: (self.size.height / max) * value, alignment: .center)

                }
            }

        }
    }
}
struct BarChart: View {
    let values : [Int]
    let max : CGFloat
    let count : CGFloat
    
    init(values : [Int]) {
        let max = values.max() ?? 0
        
        self.values = values
        self.max = CGFloat((max > 5) ? max + 2 : 7)
        self.count = CGFloat(self.values.count)
    }
    
    
    var body: some View {
        ZStack() {
            GridPath(x: CGFloat(self.values.count), y: (self.max))
                .stroke(Color.gray, lineWidth: 0.5)
            
            GeometryReader { geometry in
                HStack(spacing: 0.0) {
                    ForEach(self.values, id: \.self) { value in
                        BarChartCell(
                            size:
                                .init(
                                    width: geometry.size.width / CGFloat(self.values.count),
                                    height: geometry.size.height
                            ),
                            value: CGFloat(value),
                            max: CGFloat(self.max))
                    }
                }
            }

        }
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart(values: [ 91, 8, 3, 43, 23, 12])
    }
}
