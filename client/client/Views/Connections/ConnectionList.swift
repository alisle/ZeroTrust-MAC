//
//  ConnectionList.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/21/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionList: View {
    @EnvironmentObject var allConnections  : AllConnections
    @State private var aliveOnly = true

    func filter(_ connections: [Connection]) -> [Connection] {
        if aliveOnly {
            return connections.filter { $0.alive }
        }
        
        return connections
    }

    
    var body: some View {
        List(content: {
            Toggle(isOn: $aliveOnly) {
                 Text("Show alive connections only")
             }
            
            if self.allConnections.connections.count == 0 {
                Text("Empty.")
            } else {
                ForEach(self.filter(self.allConnections.connections)) { connection in
                    ConnectionRow(connection: connection)
                        .tag(connection.id)
                        .foregroundColor(connection.alive ? .white : .gray)
                        .onTapGesture() {
                            let controller = DetailWindowController(rootView: ConnectionDetails(connection: connection))
                            controller.showWindow(nil)
                        }
                }
            }
        })
        .listStyle(SidebarListStyle())
    }
}

struct ConnectionList_Previews: PreviewProvider {
    static var previews: some View {
        let allConnections = AllConnections()
        allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))

        return ConnectionList().environmentObject(allConnections)        
    }
}
