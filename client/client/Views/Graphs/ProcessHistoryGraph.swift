//
//  ProcessHistoryGraph.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/31/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI


struct ProcessHistoryGraph: View {
    let values : [Int]
    
    init(sha: String) {
        self.values = ProcessHistoryCache.shared.get(key: sha, step: 60 * 5, duration: 60 * 60) ?? []
    }
    
    var body: some View {
        VStack() {
            BarChart(values: self.values)
            Text("# of Connections made by Process")
                .font(.caption)
        }.padding(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
}

struct ProcessHistoryGraph_Previews: PreviewProvider {
    static var previews: some View {
        let connection = generateTestConnection(direction: .outbound)
        ProcessHistoryCache.shared.eventTriggered(event: OpenedOutboundConnectionEvent(connection: connection))
        
        return ProcessHistoryGraph(sha:connection.process.sha256!)
    }
}
