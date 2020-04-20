//
//  ConnectionUserChain.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/8/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct UserChain: View {
    let process : ProcessDetails
    let direction : ConnectionDirection
    let remoteSocket : SocketAddress
    let localSocket : SocketAddress
    let displayAddress : String
    
    init(record : RecordDetails) {
        self.process = record.process
        self.direction = record.direction
        self.remoteSocket = record.remoteSocket
        self.localSocket = record.localSocket
        self.displayAddress = record.remoteDisplayAddress
    }
    
    var body: some View {
        HStack {
            VStack {
                Image("Glasses")
                    .resizable()
                    .frame(width: 64, height: 64, alignment: .leading)
                
                Text("\(self.process.username!)(\(String(self.process.uid!)))")
                    .bold()
            }
            
            HStack {
                Spacer()
                ConnectionDirectionIcon(direction: self.direction, size: 64)
                Spacer()
            }
            
            VStack {
                if self.process.appBundle != nil {
                    BundleView(bundle: self.process.appBundle!, size: .init(width: 64, height: 64))
                } else {
                    CommandLineView(command: self.process.command!, size: .init(width: 64, height: 64))
                }
                Text("\(self.process.command!)")
                    .bold()
            }
            
            HStack {
                Spacer()
                ConnectionDirectionIcon(direction: self.direction, size: 64)
                Spacer()
            }

            VStack {
                Image("NetworkLink")
                    .resizable()
                    .frame(width: 64, height: 64, alignment: .leading)
                
                if self.direction == .outbound {
                    Text(self.remoteSocket.protocolDetails?.name ?? self.remoteSocket.portDescription)
                        .bold()
                } else {
                    Text(self.localSocket.protocolDetails?.name ?? self.localSocket.portDescription)
                        .bold()
                }
            }
            
            HStack {
                Spacer()
                ConnectionDirectionIcon(direction: self.direction, size: 64)
                Spacer()
            }

            VStack {
                Image("Globe")
                    .resizable()
                    .frame(width: 64, height: 64, alignment: .leading)
                Text(self.displayAddress)
                    .bold()
            }
            
        }
        .frame(height: 80)
    }
}

struct ConnectionUserChain_Previews: PreviewProvider {
    static var previews: some View {
        return VStack {
            Text("Outbound - Connection")
            UserChain(record: generateTestConnection(direction: .outbound))
            Spacer()
            Text("Inbound - Connection")
            UserChain(record: generateTestConnection(direction: .inbound))
            Spacer()
            Text("Query")
            UserChain(record: generateFirewallQuery())


        }
        
    }
}
