//
//  ContentView.swift
//  client
//
//  Created by Alex Lisle on 6/20/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ContentView : View  {
    
    @EnvironmentObject var connections : CurrentConnections
 
    var body: some View {
        NavigationView {
            ConnectionListView()
                .frame(minWidth: 400.0, maxWidth: 600)
            Text("Select Something")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.frame(minWidth: 800, maxWidth: 1024)
    
    }
}


#if DEBUG
func generateTestConnection() -> Connection {
    let localPort = Int.random(in: 1025..<40000)
    let remotePort = [ 80, 443, 22, 21, 8100].randomElement()
    let protocolCache = ProtocolCache()
    let remoteProtocol = protocolCache.get(port: remotePort!)
    let displayName = [ "ssh", "Google Chrome", "Mozilla Firefox", "Brave" ].randomElement()
    
    let connection = Connection(tag: UUID(),
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
                                displayName: displayName!)
    
    return connection
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        let connections = CurrentConnections()
        connections.establishedConnections = [
            generateTestConnection(),
            generateTestConnection(),
            generateTestConnection(),
            generateTestConnection()
        ]
        
        return ContentView().environmentObject(connections)
    }
}
#endif
