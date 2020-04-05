//
//  ConnectionRow.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/22/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionRow: View {
    let connection : Connection

    var body: some View {
        HStack(spacing: 5) {
            Rectangle()
                .fill(connection.outcome.color)
                .frame(width: 5, height: 32)
            ConnectionIcon(connection: connection, size: 32)
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

struct ConnectionRow_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionRow(connection: generateTestConnection(direction: ConnectionDirection.outbound))
    }
}
