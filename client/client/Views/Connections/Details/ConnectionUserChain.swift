//
//  ConnectionUserChain.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/8/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionUserChain: View {
    let connection : Connection
    
    var body: some View {
        HStack {
            VStack {
                Image("Glasses")
                    .resizable()
                    .frame(width: 64, height: 64, alignment: .leading)
                
                Text("\(self.connection.process.username!)(\(String(self.connection.process.uid!)))")
                    .bold()
            }
            
            HStack {
                Spacer()
                ConnectionDetailsDirectionIcon(direction: connection.direction, size: 64)
                Spacer()
            }
            
            VStack {
                if self.connection.process.appBundle != nil {
                    BundleView(bundle: self.connection.process.appBundle!, size: .init(width: 64, height: 64))
                } else {
                    CommandLineView(command: self.connection.process.command!, size: .init(width: 64, height: 64))
                }
                Text("\(self.connection.process.command!)")
                    .bold()
            }
            
            HStack {
                Spacer()
                ConnectionDetailsDirectionIcon(direction: connection.direction, size: 64)
                Spacer()
            }

            VStack {
                Image("NetworkLink")
                    .resizable()
                    .frame(width: 64, height: 64, alignment: .leading)
                
                Text(connection.portProtocol?.name ?? connection.remoteProtocol)
                    .bold()
            }
            
            HStack {
                Spacer()
                ConnectionDetailsDirectionIcon(direction: connection.direction, size: 64)
                Spacer()
            }

            VStack {
                Image("Globe")
                    .resizable()
                    .frame(width: 64, height: 64, alignment: .leading)
                Text(connection.remoteDisplayAddress)
                    .bold()
            }
            
        }
        .frame(height: 80)
    }
}

struct ConnectionUserChain_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionUserChain(connection: generateTestConnection(direction: .outbound))
        
    }
}
