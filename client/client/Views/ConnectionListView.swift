//
//  ConnectionListView.swift
//  client
//
//  Created by Alex Lisle on 8/13/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionListView: View {
    @EnvironmentObject var viewState : ViewState
    
    
    var body: some View {
        List {
            Section(header: Text("Alive Connections")) {
                if viewState.aliveConnections.count == 0 {
                    Text("Empty.")
                } else {
                    ForEach(viewState.aliveConnections) { connection in
                        NavigationLink(destination: ConnectionDetailsView(connection: connection)) {
                            ConnectionRowView(connection: connection)
                                .tag(connection.id)
                                .foregroundColor(.white)
                        }
                        .frame(height: 64)
                    }
                }
            }

            Section(header: Text("Dead Connections")) {
                if viewState.deadConnections.count == 0 {
                    Text("Empty.")
                } else {
                    ForEach(viewState.deadConnections) { connection in
                        NavigationLink(destination: ConnectionDetailsView(connection: connection)) {
                            ConnectionRowView(connection: connection)
                                .tag(connection.id)
                                .foregroundColor(.gray)
                        }
                    }.frame(height: 64)
                }
            }
        }
        .listStyle(SidebarListStyle())
    }
}

#if DEBUG
struct ConnectionListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewState = ViewState(aliveConnections: [
                generateTestConnection(direction: ConnectionDirection.outbound),
                generateTestConnection(direction: ConnectionDirection.outbound),
                generateTestConnection(direction: ConnectionDirection.outbound),
                generateTestConnection(direction: ConnectionDirection.outbound)
        ], deadConnections:  [
                generateTestConnection(direction: ConnectionDirection.outbound),
                generateTestConnection(direction: ConnectionDirection.outbound),
                generateTestConnection(direction: ConnectionDirection.outbound),
                generateTestConnection(direction: ConnectionDirection.outbound)
        ])

        return ConnectionListView().environmentObject(viewState)
        }
}
#endif
