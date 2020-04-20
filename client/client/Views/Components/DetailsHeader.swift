//
//  ConnectionDetailsHeader.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/30/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI
import IP2Location

struct DetailsHeader: View {
    let location : IP2LocationRecord?
    let outcome : Outcome?
    let direction : ConnectionDirection
    let process : ProcessDetails
    let remoteDisplayAddress : String
    let state : ConnectionStateType?
    let remoteSocket : SocketAddress
    
    init(record: RecordDetails, outcome : Outcome? = nil, state: ConnectionStateType? = nil) {
        self.location = record.location
        self.outcome = outcome
        self.direction = record.direction
        self.process = record.process
        self.remoteDisplayAddress = record.remoteDisplayAddress
        self.state = state
        self.remoteSocket = record.remoteSocket
    }
    

    func locationDescription() -> String {
        if let location = self.location {
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
        
        if self.remoteSocket.address.isPrivate {
            return " - Private Address Range"
        }
        
        return ""
    }
    
    var body: some View {
        let hstack = HStack(alignment: .top) {
            if self.outcome != nil {
                Rectangle()
                    .fill(self.outcome!.color)
                    .frame(width: 5)
            }
            
            ProcessDetailsIcon(processInfo: self.process, size: 64)
            VStack(alignment: .leading) {
                Text(self.process.displayName)
                    .font(.caption)
                    .opacity(0.75)
                    .padding(.init(top: 2, leading: 0, bottom: 1, trailing: 0))
                    
                Text(self.remoteDisplayAddress)
                    .font(.title)
                    .bold()
                
                HStack {
                    Text("\(self.state?.description ?? "")\(self.locationDescription())")
                        .font(.caption)
                        .opacity(0.75)
                }
                
            }
            
            Spacer()
            ConnectionDirectionIcon(direction: self.direction)
        }
        
        return hstack.frame(minWidth: 0, maxWidth: .infinity, minHeight: 70, maxHeight: 70, alignment: Alignment.topLeading)
    }
}

struct ConnectionDetailsHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Details Header")
            DetailsHeader(
                record: generateTestConnection(direction: .outbound),
                outcome: Outcome.allowed,
                state: ConnectionStateType.connected
                )
            
            Spacer()
            Text("Query Header")
            DetailsHeader(record: generateFirewallQuery())
            Spacer()
        }
    }
}
