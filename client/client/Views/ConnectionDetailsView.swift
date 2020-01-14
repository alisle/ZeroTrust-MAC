//
//  ConnectionDetailsView.swift
//  client
//
//  Created by Alex Lisle on 8/1/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionDetailsView: View {
    let connection : Connection
    
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
    
    var title: some View {
        let hstack = HStack(alignment: .top) {
            Rectangle()
                .fill(connection.outcome.color)
                .frame(width: 5)
            
            ConnectionIconView(connection: connection, size: 64)
            VStack(alignment: .leading) {
                Text(connection.displayName)
                    .font(.caption)
                    .opacity(0.75)
                Text(connection.remoteDisplayAddress)
                    .font(.title)
                    .bold()
                HStack {
                    Text("\(connection.state.description) - \(connection.country ?? "")")
                        .font(.caption)
                        .opacity(0.75)

                }
                
            }
            
        }
        
        return hstack.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
    }
    
    var metadata: some View {
        
        let timeStack = HStack() {
            createPair(prompt: "Start Time", value: "\(connection.startTimestamp.timeAgoSinceDate())")
            Spacer()
            createPair(prompt: "End Time", value: "\(getEndDate())")
        }
                
        
        let metadataStack = VStack {
            timeStack
        }.padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 0))

        return metadataStack
    }
    
    private func createPair(prompt: String, value: String) -> some View {
        return HStack {
                Text("\(prompt):").bold().multilineTextAlignment(.leading)
                Text("\(value)")
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

    }
    
    var userDetails: some View {
        let group = HStack {
            if connection.user != nil {
                if connection.uid != nil {
                    createPair(prompt: "Process Owner", value: "\(connection.user!)(\(connection.uid!))")
                } else {
                    createPair(prompt: "Process Owner", value: connection.user!)
                }
            }
        }
        
        return group
    }
    
    var processDetails: some View {
        let pid = createPair(prompt: "PID", value: "\(connection.pid)")
        let ppid = createPair(prompt: "PPID", value: "\(connection.ppid)")
        
        let group = VStack(alignment: .leading, spacing: 5) {
            Text("Process Details").font(.headline).bold()
            VStack(alignment: .leading) {
                HStack {
                    userDetails
                    Spacer()
                    Spacer()
                    pid
                    ppid
                }
            }

            if connection.process != nil {
                createPair(prompt: "Process", value: connection.process!)
            }
            
            
            if connection.processBundle != nil {
                createPair(prompt:"Process App", value: connection.processBundle!.bundlePath)
            }
            
            if connection.processTopLevelBundle != nil {
                createPair(prompt:"Top Level Process App", value: connection.processTopLevelBundle!.bundlePath)
            }
            
            if connection.parentBundle != nil {
                createPair(prompt: "Parent Process App", value : connection.parentBundle!.bundlePath)
            }
            
            if connection.parentTopLevelBundle != nil {
                createPair(prompt: "Top Level Parent Procc App", value: connection.parentTopLevelBundle!.bundlePath)
            }
        }
        
        return group
    }
    
    var protocolDetails: some View {
        let group = VStack(alignment: .leading, spacing: 5) {
            Text("Protocol Details").font(.headline).bold()
            createPair(prompt:"Type", value:"\(connection.portProtocol!.name) - \(connection.portProtocol!.port)")
            Text(connection.portProtocol!.description)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(minWidth: 500,
                       maxWidth: .infinity,
                       minHeight: 50,
                       idealHeight: 100,
                       maxHeight: .infinity,
                       alignment: .topLeading)
        }
        
        return group
    }
    
    var body: some View {
        let list = List {
            title
            VStack {
                metadata
                ProcessChainView(connection: connection)
                    .frame(minWidth: 600)
                processDetails
                Spacer()
                ProtocolChainView(connection: connection)
                    .frame(minWidth: 600)

                if connection.portProtocol != nil {
                    protocolDetails
                } else {
                    createPair(prompt: "Remote Port", value: "\(connection.remotePort)")
                }
            }            
        }
        
        return list
    }
}

#if DEBUG
struct ConnectionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionDetailsView(connection: generateTestConnection(direction: ConnectionDirection.outbound))
    }
}
#endif
