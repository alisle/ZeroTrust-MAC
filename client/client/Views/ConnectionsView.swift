//
//  ContentView.swift
//  client
//
//  Created by Alex Lisle on 6/20/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI


struct ConnectionsView : View  {
    
    @EnvironmentObject var viewState : ViewState
    @EnvironmentObject var serviceState : ServiceState

    var connectionsContainer : some View {
        VStack(alignment: .leading) {
            NavigationView {
                ConnectionListView()
                    .frame(minWidth: 400, maxWidth: 600, minHeight: 200)
                
                if serviceState.enabled {
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
            ConnectionsViewHeader()
            ConnectionCombinedGraphView()
            connectionsContainer
        }.frame(minWidth: 1200, maxWidth: .infinity)
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
    let process = ["Chrome.app", "/usr/bin/ssh", "WhatsApp.app"].randomElement()
    
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
                                portProtocol: remoteProtocol,
                                remoteURL: "www.google.com",
                                remoteSocket: SocketAddress(address: IPAddress("192.168.2.3")!, port: remotePort!),
                                localSocket : SocketAddress(address: IPAddress("0.0.0.0")!, port: localPort),
                                process: process,
                                parentProcess: "Chrome.app",
                                processBundle: nil,
                                parentBundle: nil,
                                processTopLevelBundle: nil,
                                parentTopLevelBundle: nil,
                                displayName: displayName!,
                                country: "US")
    
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

        return ConnectionsView().environmentObject(viewState)
    }
}
#endif
