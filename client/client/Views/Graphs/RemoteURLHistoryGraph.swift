//
//  RemoteURLHistoryGraph.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/1/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct RemoteURLHistoryGraph: View {
    let values : [Int]
    
    init(remoteURL: String) {
        self.values = RemoteHistoryCache.shared.get(key: remoteURL, step: 60 * 5, duration: 60 * 60) ?? []
    }
    
    var body: some View {
        VStack() {
            BarChart(values: self.values)
            Text("# of Connections made to remote host")
                .font(.caption)
        }.padding(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
}

struct RemoteURLHistoryGraph_Previews: PreviewProvider {
    static var previews: some View {
        let connection = generateTestConnection(direction: .outbound)
        ProcessHistoryCache.shared.eventTriggered(event: OpenedOutboundConnectionEvent(connection: connection))
        
        return RemoteURLHistoryGraph(remoteURL: connection.remoteURL!)
    }
}
