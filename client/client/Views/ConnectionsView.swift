//
//  ContentView.swift
//  client
//
//  Created by Alex Lisle on 6/20/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI
import IP2Location

struct ConnectionsView : View  {
    
    @EnvironmentObject var viewState : ViewState
    @EnvironmentObject var serviceState : ServiceState

    var connectionsContainer : some View {
        VStack(alignment: .leading) {
            NavigationView {
                ConnectionList()
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
        /*
        VStack(alignment: .leading) {
            ConnectionsViewHeader()
            ConnectionCombinedGraphView()
            connectionsContainer
        }.frame(minWidth: 1200, maxWidth: .infinity)
 */
        Overview()
    }
}


#if DEBUG
func generateTestRules() -> Rules {
    var json : JSONRules  = Helpers.loadJSON("rules.json")
    json.hostnames.sort()
    json.domains.sort()
    
    return json.convert()
}

func generateProcessInfo(_ generatePeers : Bool = true, _ numberOfPeers : Int = 4) -> ProcessDetails {
    let process = ["Chrome.app", "/usr/bin/ssh", "WhatsApp.app"].randomElement()

    let parent = (generatePeers) ? generateProcessInfo(false) : nil
    let peers = (generatePeers) ? (0..<numberOfPeers).map{ _ in generateProcessInfo(false) } : []
    
    print("Theses are peers \(peers)")
    return ProcessDetails(
        pid: Int.random(in: 1000...4000),
        ppid: 1020,
        uid: 1000,
        username: "alisle",
        command: process,
        path: "/usr/bin/ssh",
        parent: parent,
        bundle: nil,
        appBundle: nil,
        sha256: "012012",
        md5: "1231",
        peers: peers
    )
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


func generateIP2LocationRecord() -> IP2LocationRecord? {
    if let filepath = Bundle.main.url(forResource: "IP2LOCATION-LITE-DB11", withExtension: "BIN") {
        do {
            let db = try IP2DBLocate(file: filepath)
            return db.find("8.8.8.8")
        } catch  {
            return nil
        }
    }
    
    return nil
}

func generateTestConnection(direction: ConnectionDirection, includeLocation : Bool = false) -> Connection {
    let tcpConnection = generateTCPConnection()
    let protocolCache = ProtocolCache()
    let remoteProtocol = protocolCache.get(tcpConnection.remoteSocket.port)
    let connection = Connection(
        connection: generateTCPConnection(),
        location: includeLocation ? generateIP2LocationRecord() : nil,
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

        let serviceState = ServiceState()
        
        let view = ConnectionsView()
            .environmentObject(viewState)
            .environmentObject(serviceState)
        
        return view
    }
}
#endif
