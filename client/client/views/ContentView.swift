//
//  ContentView.swift
//  client
//
//  Created by Alex Lisle on 6/20/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionView : View {
    let connection : Connection
    init(connection: Connection) {
        self.connection = connection;
    }
    
    var body : some View {
        HStack {
            if connection.processTopLevelBundle?.icon != nil {
                Image(nsImage: connection.processTopLevelBundle!.icon!).resizable().frame(width: 50, height: 50).aspectRatio(CGSize(width: 50, height: 50), contentMode: .fit)
            }
            
            
            HStack() {
                VStack(alignment: .leading) {
                    Text(connection.displayName).font(.headline)
                    HStack {
                        Text("Address:").font(.subheadline)
                        Text(connection.remoteDisplayAddress).font(.subheadline)
                        Text("Port:").font(.subheadline).font(.subheadline)
                        Text(String(connection.remotePort)).font(.subheadline)
                    }
                    
                    if connection.user != nil {
                        HStack {
                            Text("User:").font(.subheadline)
                            Text(connection.user!).font(.subheadline)
                        }
                    }
                    
                    HStack {
                        Text("State:").font(.subheadline)
                        Text(connection.state.description).font(.subheadline)
                    }
                    
                }
            }
        }
    }
}

struct ConnectionListView : View {
    @EnvironmentObject var connections : Connections
    var body: some View {
        List(connections.establishedConnections) {
            connection in VStack(alignment: .leading) {
                ConnectionView(connection: connection)
                Divider()
            }
        }
    }
}

struct ContentView : View  {
    
    @EnvironmentObject var connections : Connections
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                Divider()
                Text("Current Connections").font(.title)
                ConnectionListView()
            }
        }.offset(CGSize(width: 0, height: 17))
    }
    
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
