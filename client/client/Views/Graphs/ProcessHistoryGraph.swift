//
//  ProcessHistoryGraph.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/31/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI


struct ProcessHistoryGraph: View {
    let items : [ChartItem]
    
    init(sha: String) {
        self.items = (ProcessHistoryCache.shared.get(key: sha, step: 60 * 5, duration: 60 * 60) ?? []).enumerated().map{ ChartItem(label: "-\((12 - $0.offset) * 5)", value: $0.element) }
    }
    
    var body: some View {
        VStack() {
            BarChart(
                items: self.items,
                caption: "# of Connections made by Process"
            )
        }
    }
}

struct ProcessHistoryGraph_Previews: PreviewProvider {
    static var previews: some View {
        let connection = generateTestConnection(direction: .outbound)
        ProcessHistoryCache.shared.eventTriggered(event: OpenedConnectionEvent(connection: connection))
        return VStack {
            HStack {
                ProcessHistoryGraph(sha:connection.process.sha256!)
                ProcessHistoryGraph(sha:connection.process.sha256!)
            }
            Spacer()
            
            HStack {
                ProcessHistoryGraph(sha:connection.process.sha256!)
            }

        }
    }
}
