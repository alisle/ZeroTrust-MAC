//
//  ProtocolDetailsView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/2/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct PortProtocol : View {
    let proto : Protocol
    
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
    let connection : Connection
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(connection.remoteSocket.port)")
                .bold()
                .font(.title)
                .padding(.init(top: 2, leading: 0, bottom: 5, trailing: 0))

            Text("Hmmm, this isn't a port which is well known to us")
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
    }
}
struct ProtocolDetailsView: View {
    let connection : Connection
    
    var body: some View {
        VStack {
            if connection.portProtocol != nil {
                PortProtocol(proto: connection.portProtocol!)
            } else {
                UnknownProtocol(connection: connection)
            }
        }
    }
}

struct ProtocolDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Protocol View")
            PortProtocol(proto: generateTestConnection(direction: .outbound).portProtocol!)
            
            Text("Protocol Details")
            ProtocolDetailsView(connection: generateTestConnection(direction: .outbound))

            Text("UnknownProtocol Details")
            UnknownProtocol(connection: generateTestConnection(direction: .outbound))

        }
    }
}
