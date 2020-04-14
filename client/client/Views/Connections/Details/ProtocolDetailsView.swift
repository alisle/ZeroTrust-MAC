//
//  ProtocolDetailsView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/2/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct PortProtocol : View {
    let proto : PortProtocolDetails
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(proto.name) - \(String(proto.port))")
                .bold()
                .font(.title)
                .padding(.init(top: 2, leading: 0, bottom: 5, trailing: 0))

            Text("\(proto.description)")
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            Text("\(String(proto.url))")
                .font(.caption)
                .opacity(0.75)
                .padding(.init(top: 19, leading: 0, bottom: 10, trailing: 0))

            Spacer()
        }
    }
}

struct UnknownProtocol : View {
    let socket : SocketAddress
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(socket.port)")
                    .bold()
                    .font(.title)
                    .padding(.init(top: 2, leading: 0, bottom: 5, trailing: 0))
                Spacer()
            }
            
            Text("Hmmm, this isn't a port which is well known to us")
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}
struct ProtocolDetailsView: View {
    let socket : SocketAddress
    
    init(connection: Connection) {
        switch(connection.direction) {
        case .inbound: self.socket = connection.localSocket
        case .outbound: self.socket = connection.remoteSocket
        }
    }
    
    var body: some View {
        VStack {
            if socket.protocolDetails != nil {
                PortProtocol(proto: socket.protocolDetails!)
            } else {
                UnknownProtocol(socket: socket)
            }
        }
    }
}

struct ProtocolDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Protocol View")
            PortProtocol(proto: generateTestConnection(direction: .outbound).remoteSocket.protocolDetails!)
            
            Text("Protocol Details")
            ProtocolDetailsView(connection: generateTestConnection(direction: .outbound))

            Text("UnknownProtocol Details")
            UnknownProtocol(socket: generateTestConnection(direction: .outbound).remoteSocket)

        }
    }
}
