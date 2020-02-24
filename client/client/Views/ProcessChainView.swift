//
//  ProcessTreeView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 12/5/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ProcessChainView: View {
    let connection : Connection
    
    private func getImage(bundle: Optional<Bundle>) -> Image {
        if let nsimage = bundle?.icon {
            return Image(nsImage: nsimage)
        }
        
        return Image("Console")
    }
    
    private func getText(bundle: Optional<Bundle>) -> String {
        if let name = bundle?.bundleURL.lastPathComponent {
            return name;
        }
        
        return "Unknown"
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
                    Image("Glasses")
                       .resizable()
                       .frame(width: 64, height: 64, alignment: .leading)
                    Text(connection.process.username ?? "Unknown")
                }
            }
            
            ArrowView()
            .frame(minWidth: 20, maxWidth: 100)

            VStack {
                HStack {
                    getImage(bundle: connection.process.parent?.appBundle)
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .leading)
                    Text(getText(bundle: connection.process.parent?.appBundle))
                }
            }
            
            ArrowView()
                .frame(minWidth: 20, maxWidth: 100)

            VStack {
                HStack {
                    getImage(bundle: connection.process.appBundle)
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .leading)
                    Text(chopString(connection.process.path))
                }
            }
        }
    
    }
}

struct ProcessTreeView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessChainView(connection: generateTestConnection(direction: .outbound))
    }
}
