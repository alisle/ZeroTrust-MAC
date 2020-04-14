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
    let item : ChartItem
    let max : CGFloat
    let scale : CGFloat
    
    let gradient : Gradient = Gradient(colors: [
        Color.init(.sRGBLinear, red: 0.1, green: 0.01, blue: 0.1, opacity: 1.0),
        Color.init(.sRGBLinear, red: 0.2, green: 0.01, blue: 0.1, opacity: 1.0)
    ])
    
    init(size: CGSize, item: ChartItem, max: CGFloat) {
        self.size = size
        self.item = item
        self.max = max
        self.scale = (1 / max) * CGFloat(item.value)
    }

    var body: some View {
        
        VStack {
            Spacer()
            if item.value != 0 {
                Text("\(item.value)")
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(gradient: self.gradient, startPoint: .bottom, endPoint: .top))
                    .frame(
                        width: self.size.width,
                        height: self.scale * self.size.height
                    )
                
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.red)
                    .frame(
                        width: self.size.width,
                        height: self.scale * self.size.height
                    )
            }
            
            Text(item.label)
        }
    }
}

struct ChartItem {
    let label : String
    let value : Int
}

extension ChartItem : Comparable {
    static func < (lhs: ChartItem, rhs: ChartItem) -> Bool {
        return lhs.value < rhs.value
    }
}

extension ChartItem : Identifiable {
    var id : String {
        get { return self.label }
    }
}

struct BarChart: View {
    let items : [ChartItem]
    let max : CGFloat
    let count : CGFloat
    let caption : String
    
    init(items : [ChartItem], caption: String) {
        let max = items.max()?.value ?? 0
        self.items = items
        self.count = CGFloat(self.items.count)
                         
        if max <= 5 {
            self.max = 10
        } else if max <= 10 {
            self.max = 20
        } else if max <= 100 {
            self.max = CGFloat(max + (10 - (max % 10)))
        } else if max <= 1000 {
            self.max = CGFloat(max + (50 - (max % 50)))
        } else  {
            self.max = CGFloat(max + (100 - (max % 100)))
        }
        
        self.caption = caption

    }
    
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(alignment: .lastTextBaseline, spacing: 0.1) {
                    ForEach(self.items) { item in
                        BarChartCell(
                            size:
                                .init(
                                    width: (geometry.size.width - 10) / CGFloat(self.items.count),
                                    height: geometry.size.height - 20
                                ),
                            item: item,
                            max: self.max
                        )
                    }
                }
            }
            
            Text(self.caption)
                .font(.caption)
                .padding(.init(top: 5, leading: 1, bottom: 1, trailing: 1))
        }
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Large Range")
            BarChart( items : [
                    ChartItem(label: "Test 67", value: 67),
                    ChartItem(label: "Test 100", value: 100),
                    ChartItem(label: "Test 50", value: 50),
                    ChartItem(label: "Test 200", value: 200),
                    ChartItem(label: "Test 700", value: 700),
                    ChartItem(label: "Test 400", value: 400),
                    ChartItem(label: "Test 600", value: 600),
                ],
                caption: "This is the caption"
            )
            
            Spacer()
            Text("Large Range")
            BarChart(
                items: [
                    ChartItem(label: "Test 0", value: 0),
                    ChartItem(label: "Test 10", value: 10),
                    ChartItem(label: "Test 20", value: 20),
                    ChartItem(label: "Test 30", value: 30),
                    ChartItem(label: "Test 40", value: 40),
                    ChartItem(label: "Test 50", value: 50),
                    ChartItem(label: "Test 60", value: 60),
                ],
                caption: "This is the caption"
            )

        }
    }
}
