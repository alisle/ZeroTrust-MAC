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

func generateProcessInfo() -> ProcessInfo {
    let process = ["Chrome.app", "/usr/bin/ssh", "WhatsApp.app"].randomElement()

    return ProcessInfo(
        pid: 1021,
        ppid: 1020,
        uid: 1000,
        username: "alisle",
        command: process,
        path: "/usr/bin/ssh",
        parent: nil,
        bundle: nil,
        appBundle: nil,
        sha256: "012012",
        md5: "1231")
}

func generateTCPConnection() -> TCPConnection {
    let localPort = Int.random(in: 1025..<40000)
    let remotePort = [ 80, 443, 22, 21, 8100].randomElement()

    return TCPConnection(
        tag: UUID(),
        timestamp: Date().timeIntervalSince1970,
        inbound: false,
        process: generateProcessInfo(),
        remoteSocket: SocketAddress(address: IPAddress("192.168.2.3")!, port: remotePort!),
        localSocket: SocketAddress(address: IPAddress("0.0.0.0")!, port: localPort),
        outcome: Outcome.allowed
    )
}

func generateTestConnection(direction: ConnectionDirection) -> Connection {
    let tcpConnection = generateTCPConnection()
    let protocolCache = ProtocolCache()
    let remoteProtocol = protocolCache.get(tcpConnection.remoteSocket.port)
    let displayName = [ "ssh", "Google Chrome", "Mozilla Firefox", "Brave" ].randomElement()
    
    let connection = Connection(
        connection: generateTCPConnection(),
        country: "US",
        remoteURL: "www.google.com",
        portProtocol: remoteProtocol
    )
    
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
