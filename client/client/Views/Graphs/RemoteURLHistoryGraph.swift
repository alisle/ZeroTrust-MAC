//
//  RemoteURLHistoryGraph.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/1/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct RemoteURLHistoryGraph: View {
    let items : [ChartItem]
        
    init(remoteURL: String) {
        self.items = (RemoteHistoryCache.shared.get(key: remoteURL, step: 60 * 5, duration: 60 * 60) ?? []).enumerated().map{ ChartItem(label: "-\((12 - $0.offset) * 5)", value: $0.element) }
    }
    
    var body: some View {
        VStack() {
            BarChart( items: self.items, caption: "# of Connections made to remote host")
        }
    }
}

struct RemoteURLHistoryGraph_Previews: PreviewProvider {
    static var previews: some View {
        let connection = generateTestConnection(direction: .outbound)
        ProcessHistoryCache.shared.eventTriggered(event: OpenedConnectionEvent(connection: connection))
        
        return RemoteURLHistoryGraph(remoteURL: connection.remoteURL!)
    }
}
