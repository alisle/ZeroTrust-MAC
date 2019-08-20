//
//  ConnectionListView.swift
//  client
//
//  Created by Alex Lisle on 8/13/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionListView: View {
    @EnvironmentObject var connections : CurrentConnections
    
    var body: some View {        
        List {
            Section(header: Text("Current Connections")) {
                ForEach(connections.establishedConnections) { connection in
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
            connections.establishedConnections = [
                generateTestConnection(),
                generateTestConnection(),
                generateTestConnection(),
                generateTestConnection()
            ]
            
        return ConnectionListView().environmentObject(connections)
        }
}
#endif
