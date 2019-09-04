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
        if let end = connection.endDateTimestamp {
            return end.timeAgoSinceDate()
        } else {
            return "Ongoing"
        }
    }
    
    var title: some View {
        let hstack = HStack(alignment: .top) {
            ConnectionIconView(connection: connection)
            VStack(alignment: .leading) {
                Text(connection.displayName)
                    .font(.caption)
                    .opacity(0.75)
                Text(connection.remoteDisplayAddress)
                    .font(.title)
                    .bold()
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
        
        let stateStack = HStack() {
            createPair(prompt: "Direction", value: "\(connection.direction.description)")
            Spacer()
            createPair(prompt: "Current State", value: "\(connection.state.description)")
            Spacer()
            createPair(prompt: "Decision", value: "\(connection.outcome.description)")
        }
        
        let metadataStack = VStack {
            timeStack
            stateStack
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
        let pid = createPair(prompt: "Process ID", value: "\(connection.pid)")
        let ppid = createPair(prompt: "Parent Process ID", value: "\(connection.ppid)")
        
        let group = VStack(alignment: .leading, spacing: 5) {
            Text("Process Details").font(.headline).bold()
            HStack {
                userDetails
                Spacer()
                pid
                Spacer()
                ppid
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
                processDetails
                Spacer()
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
