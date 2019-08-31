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
        let hstack = HStack() {
            Text("Start Date: \(connection.startTimestamp.timeAgoSinceDate())")
            Spacer()
            Text("End Date: \(getEndDate())")
            Spacer()
            Text("Current State: \(connection.state.description)")
        }

        return hstack
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
                    createPair(prompt: "User", value: "\(connection.user!)(\(connection.uid!))")
                } else {
                    createPair(prompt: "User", value: connection.user!)
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
                createPair(prompt:"Process Bundle", value: connection.processBundle!.bundlePath)
            }
            
            if connection.processTopLevelBundle != nil {
                createPair(prompt:"Top Level Bundle", value: connection.processTopLevelBundle!.bundlePath)
            }
            
            if connection.parentBundle != nil {
                createPair(prompt: "Parent Bundle", value : connection.parentBundle!.bundlePath)
            }
            
            if connection.parentTopLevelBundle != nil {
                createPair(prompt: "Parent Top Level Bundle", value: connection.parentTopLevelBundle!.bundlePath)
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
        ConnectionDetailsView(connection: generateTestConnection())
    }
}
#endif
