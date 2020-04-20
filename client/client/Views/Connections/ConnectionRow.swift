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
            ProcessDetailsIcon(processInfo: connection.process, size: 32)
            VStack(alignment: .leading) {
                Text(connection.process.displayName).bold()
                HStack {
                    Text(connection.remoteDisplayAddress)
                    Spacer()
                    if connection.direction == .outbound {
                        Text("\(connection.remoteSocket.portDescription)")
                    } else {
                        Text("\(connection.localSocket.portDescription)")
                    }
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
