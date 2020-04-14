//
//  ConnectionDetailsHeader.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/30/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionDetailsHeader: View {
    let connection : Connection

    func locationDescription() -> String {
        if let location = connection.location {
            if location.iso != "-" {
                var description = location.city ?? ""
                if description.count > 0 {
                    description.append(",")
                }
                
                description.append(location.region ?? "")
                if description.count > 0 {
                    description.append(",")
                }
                
                description.append(location.country ?? "")
                return " - \(description)"
            }
        }
        
        if connection.remoteSocket.address.isPrivate {
            return " - Private Address Range"
        }
        
        return ""
    }
    
    var body: some View {
        let hstack = HStack(alignment: .top) {
            Rectangle()
                .fill(connection.outcome.color)
                .frame(width: 5)
            
            ProcessDetailsIcon(processInfo: connection.process, size: 64)
            VStack(alignment: .leading) {
                Text(connection.displayName)
                    .font(.caption)
                    .opacity(0.75)
                    .padding(.init(top: 2, leading: 0, bottom: 1, trailing: 0))
                    
                Text(connection.remoteDisplayAddress)
                    .font(.title)
                    .bold()
                
                HStack {
                    Text("\(connection.state.description)\(self.locationDescription())")
                        .font(.caption)
                        .opacity(0.75)
                }
                
            }
            
            Spacer()
            ConnectionDetailsDirectionIcon(direction: connection.direction)
        }
        
        return hstack.frame(minWidth: 0, maxWidth: .infinity, minHeight: 70, maxHeight: 70, alignment: Alignment.topLeading)
    }
}

struct ConnectionDetailsHeader_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionDetailsHeader(connection: generateTestConnection(direction: .outbound))
    }
}
