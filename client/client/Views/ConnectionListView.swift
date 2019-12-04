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
    @State private var aliveOnly = false
    
    let categories : [FilterCategory] = Array(FilterCategory.allCases)

    func connectionList(_ category: FilterCategory) -> [Connection] {
        if aliveOnly {
            return self.viewState.connections[category]!.filter{ $0.alive }
        }
        
        return self.viewState.connections[category]!
    }
    
    var body: some View {
        List(content: {
            Toggle(isOn: $aliveOnly) {
                Text("Show alive connections only")
            }
            ForEach(categories) { category in
                Section(header: Text("Connections: \(category.description)")) {
                    if self.connectionList(category).count == 0 {
                        Text("Empty.")
                    } else {
                        ForEach(self.connectionList(category)) { connection in
                            NavigationLink(destination: ConnectionDetailsView(connection: connection)) {
                                ConnectionRowView(connection: connection)
                                    .tag(connection.id)
                                    .foregroundColor(connection.alive ? .white : .gray)
                            }
                            .frame(height: 64)
                        }
                    }
                }
            }
        }).listStyle(SidebarListStyle())
    }
}

#if DEBUG
struct ConnectionListView_Previews: PreviewProvider {
    static var previews: some View {
            let viewState = ViewState()
            viewState.connectionChanged(generateTestConnection(direction: ConnectionDirection.outbound))
            viewState.connectionChanged(generateTestConnection(direction: ConnectionDirection.outbound))
            viewState.connectionChanged(generateTestConnection(direction: ConnectionDirection.outbound))
            viewState.connectionChanged(generateTestConnection(direction: ConnectionDirection.outbound))
            viewState.connectionChanged(generateTestConnection(direction: ConnectionDirection.outbound))
            viewState.connectionChanged(generateTestConnection(direction: ConnectionDirection.outbound))
            return ConnectionListView().environmentObject(viewState)
        }
}
#endif
