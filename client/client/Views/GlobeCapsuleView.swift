//
//  GlobeCapsuleView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 11/13/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct GlobeCapsuleView: View {
    let connection : Connection
    var body: some View {
        var color = Color.green
        
        if connection.outcome != .allowed {
            color = Color.red
        } else {
            if connection.state != .connecting && connection.state != .connected {
                color = Color.gray
            }
        }
        
        let stack = ZStack {
            Capsule()
                .fill(Color.black)
                .frame(height: 40)
            
            Capsule()
                .stroke(color, lineWidth: 5)
                .frame(height: 40)

            HStack(alignment: .center) {
                ConnectionIconView(connection: connection, size: 32)
                VStack(alignment: .center) {
                    HStack {
                        Text(connection.remoteDisplayAddress)
                            .bold()
                    }.frame(height: 40)
                }.frame(height: 40)
            }.padding(10)
        }
        
        
        return stack

    }
}

struct GlobeCapsuleView_Previews: PreviewProvider {
    static var previews: some View {
        return GlobeCapsuleView(connection: generateTestConnection(direction: .outbound))
    }
}
