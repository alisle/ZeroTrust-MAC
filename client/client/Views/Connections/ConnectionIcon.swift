//
//  ConnectionIcon.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/22/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI


struct ConnectionIcon: View {
    let connection : Connection
    let size : CGFloat
     var body: some View {
         Group() {
             if connection.image == nil {
                 Image("Console")
                    .resizable()
                    .frame(width: size, height: size, alignment: .leading)
             } else {
                 Image(nsImage: connection.image!)
                    .resizable()
                    .frame(width: size, height: size, alignment: .leading)
             }
         }
     }
    
}

#if DEBUG
struct ConnectionIcon_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionIcon(connection: generateTestConnection(direction: ConnectionDirection.outbound), size: 64)
    }
}
#endif
