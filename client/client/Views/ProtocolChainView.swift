//
//  ProtocolChainView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 12/11/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ProtocolChainView: View {
    let connection : Connection
    
    private func getImage(bundle: Optional<Bundle>) -> Image {
        if let nsimage = bundle?.icon {
            return Image(nsImage: nsimage)
        }
        
        return Image("Console")
    }

    private func chopString(_ text: Optional<String>) -> String {
        if let text = text {
            let url = URL(fileURLWithPath: text)
            return url.lastPathComponent
        }
        
        return "Unknown"
    }
    
    var body: some View {
        HStack() {
            VStack {
                HStack {
                    getImage(bundle: connection.process.bundle)
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .leading)
                    Text(chopString(connection.process.command))
                }
            }

            ArrowView()
            .frame(minWidth: 20, maxWidth: 100)

            VStack {
                HStack {
                    Image("NetworkLink")
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .leading)
                    Text(connection.portProtocol?.name ?? connection.remoteProtocol)
                }
            }
            
            ArrowView()
            .frame(minWidth: 20, maxWidth: 100)

            VStack {
                HStack {
                    Image("Globe")
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .leading)
                    Text(connection.remoteDisplayAddress)
                }
            }
        }
    }
}

struct ProtocolChainView_Previews: PreviewProvider {
    static var previews: some View {
        ProtocolChainView(connection: generateTestConnection(direction: .outbound))
    }
}
