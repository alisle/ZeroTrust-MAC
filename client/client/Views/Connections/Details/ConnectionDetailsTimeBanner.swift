//
//  ConnectionDetailsTimeBanner.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/30/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionDetailsTimeBanner: View {
    let connection: Connection
    
    func getEndDate() -> String {
        if connection.state == .disconnected ||
            connection.state == .disconnecting ||
            connection.state == .closed {
            if let end = connection.endDateTimestamp {
                return end.timeAgoSinceDate()
            }
        }
        
        return "Ongoing"
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text("Start Time:")
                        .bold()
                    Text("\(self.connection.startTimestamp.timeAgoSinceDate())")
                    Spacer()
                }
                .frame(width: geometry.size.width / 2)
                
                HStack(alignment: .center) {
                    Text("End Time:")
                        .bold()
                    Text("\(self.getEndDate())")
                    Spacer()
                }
                .frame(width: geometry.size.width / 2)
            }
        }
        .padding(4)
        .frame(height: 20, alignment: .leading)
    }
}

struct ConnectionDetailsTimeBanner_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionDetailsTimeBanner(connection: generateTestConnection(direction: .outbound))
    }
}
