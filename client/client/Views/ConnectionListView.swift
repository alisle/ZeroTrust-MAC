//
//  ConnectionListView.swift
//  client
//
//  Created by Alex Lisle on 8/13/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionListView: View {
    let filter : ViewLength
    @EnvironmentObject var connections : CurrentConnections
    
    var body: some View {        
        List {
            Section(header: Text(filter.description)) {
                ForEach(connections.connections[filter] != nil ? connections.connections[filter]! : []) { connection in
                    NavigationLink(destination: ConnectionDetailsView(connection: connection)) {
                        ConnectionRowView(connection: connection)
                            .tag(connection.id)
                    }
                }
            }
        }.listStyle(SidebarListStyle())
    }
}

#if DEBUG
struct ConnectionListView_Previews: PreviewProvider {
    static var previews: some View {
        let connections = CurrentConnections()
        
        connections.connections[.current] = [
                generateTestConnection(direction: ConnectionDirection.outbound),
                generateTestConnection(direction: ConnectionDirection.outbound),
                generateTestConnection(direction: ConnectionDirection.outbound),
                generateTestConnection(direction: ConnectionDirection.outbound)
        ]
            
        return ConnectionListView(filter: .current).environmentObject(connections)
        }
}
#endif
