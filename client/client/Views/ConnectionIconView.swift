//
//  ConnectionIcon.swift
//  client
//
//  Created by Alex Lisle on 8/13/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionIconView: View {
    let connection : Connection
     var body: some View {
         Group() {
             if connection.image == nil {
                 Image("Console").resizable().frame(width: 64, height: 64, alignment: .leading)
             } else {
                 Image(nsImage: connection.image!).resizable().frame(width: 64, height: 64, alignment: .leading)
             }
         }
     }
    
}

#if DEBUG
struct ConnectionIcon_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionIconView(connection: generateTestConnection(direction: ConnectionDirection.outbound))
    }
}
#endif
