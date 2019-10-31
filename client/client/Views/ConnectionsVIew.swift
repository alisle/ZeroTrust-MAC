//
//  ContentView.swift
//  client
//
//  Created by Alex Lisle on 6/20/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI


struct ConnectionsVIew : View  {
    
    @EnvironmentObject var viewState : ViewState
    
    var header : some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Zero Trust - Connections")
                    .bold()
            }
        }
        .padding()
    }

    var connectionsContainer : some View {
        VStack(alignment: .leading) {
            NavigationView {
                ConnectionListView()
                    .frame(minWidth: 400, maxWidth: 600, minHeight: 200)
                
                if viewState.enabled {
                    Text("Such Empty!")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Not Enabled")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            header
            ConnectionGraphView()
            connectionsContainer
        }.frame(minWidth: 800, maxWidth: .infinity)
    }
}


#if DEBUG
func generateTestRules() -> Rules {
    var json : JSONRules  = Helpers.loadJSON("rules.json")
    json.hostnames.sort()
    json.domains.sort()
    
    return json.convert()
}

func generateTestConnection(direction: ConnectionDirection) -> Connection {
    let localPort = Int.random(in: 1025..<40000)
    let remotePort = [ 80, 443, 22, 21, 8100].randomElement()
    let protocolCache = ProtocolCache()
    let remoteProtocol = protocolCache.get(remotePort!)
    let displayName = [ "ssh", "Google Chrome", "Mozilla Firefox", "Brave" ].randomElement()
    
    let connection = Connection(direction: direction,
                                outcome: Outcome.allowed,
                                tag: UUID(),
                                start: Date(),
                                pid: 1021,
                                ppid: 1020,
                                uid: 1000,
                                user: "alisle",
                                remoteAddress: "192.168.2.3",
                                remoteURL: "www.google.com",
                                portProtocol: remoteProtocol,
                                localAddress: "0.0.0.0",
                                localPort: localPort,
                                remotePort: remotePort!,
                                process: "Chrome.app",
                                parentProcess: "Chrome.app",
                                processBundle: nil,
                                parentBundle: nil,
                                processTopLevelBundle: nil,
                                parentTopLevelBundle: nil,
                                displayName: displayName!,
                                country: "UK")
    
    return connection
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        let viewState = ViewState( aliveConnections: [
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

        return ConnectionsVIew().environmentObject(viewState)
    }
}
#endif
