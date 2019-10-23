//
//  ConnectionRow.swift
//  client
//
//  Created by Alex Lisle on 8/12/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionRowView: View {
    let connection : Connection
    var body: some View {
        HStack(spacing: 5) {
            Rectangle()
                .fill(connection.outcome.color)
                .frame(width: 5, height: 64)
            ConnectionIconView(connection: connection)
            VStack(alignment: .leading) {
                Text(connection.displayName).bold()
                HStack {
                    Text(connection.remoteDisplayAddress)
                    Spacer()
                    Text("\(connection.remoteProtocol)")
                }
            }
        }
    }
}


#if DEBUG
struct ConnectionRow_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionRowView(connection: generateTestConnection(direction: ConnectionDirection.outbound))
    }
}
#endif
