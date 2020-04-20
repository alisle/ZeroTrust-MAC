//
//  ConnectionDetails.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/24/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct RecordDetailsView: View {
    let record : RecordDetails
    let outcome : Outcome?
    let state : ConnectionStateType?
    let start : Date?
    let end: Date?
    
    init(connection: Connection) {
        self.outcome = connection.outcome
        self.state = connection.state
        self.record = connection
        self.start = connection.startTimestamp
        self.end = connection.endDateTimestamp
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                DetailsHeader(
                    record: self.record,
                    outcome: self.outcome,
                    state: self.state
                )
                
                if self.start != nil && self.start != nil {
                    TimeBanner(
                        state: self.state!,
                        start: self.start!,
                        end: self.end
                    )
                }
                
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        if self.record.process.sha256 != nil {
                            ProcessHistoryGraph(sha: self.record.process.sha256!)
                                .frame(width: geometry.size.width / 2, height: 200)
                        } else {
                            Text("Unknown Process")
                                .frame(width: geometry.size.width / 2, height: 200)
                        }

                        RemoteURLHistoryGraph(remoteURL: self.record.remoteDisplayAddress)
                            .frame(width: geometry.size.width / 2, height: 200)
                    }
                }
                .frame(height: 200, alignment: .center)
                .padding()
                
                VStack(alignment: .leading, spacing: 1.0) {
                    Text("Connection Overview")
                        .font(.subheadline)
                        .bold()
                    
                    UserChain(record: record)
                    .padding()
                }
                .padding(.init(top: 20, leading: 5, bottom: 5, trailing: 1))
                
                VStack(alignment: .leading, spacing: 1.0) {
                    Text("Process Making Connection")
                        .font(.subheadline)
                        .bold()

                    ProcessDetailsView(process: self.record.process)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Protocol Details")
                            .font(.subheadline)
                            .bold()

                        ProtocolDetailsView(record: self.record)
                    }
                    .frame(height: 200, alignment: .center)
                            
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Location Details")
                            .font(.subheadline)
                            .bold()
                        LocationDetails(location: self.record.location)
                    }
                }                
                
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 1.0) {
                                Text("Process Call Tree")
                                    .font(.subheadline)
                                    .bold()

                                Text("This is the chain of processes which culminated in making the connection")
                                .padding(2)
                            }.padding(.init(top: 20, leading: 5, bottom: 5, trailing: 1))
                            
                            ProcessDetailsCallTree(process: self.record.process)
                        }.frame(width: geometry.size.width)
                    }
                }.frame(height: 300, alignment: .center)
 
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 1.0) {
                                Text("Process Peers")
                                    .font(.subheadline)
                                    .bold()
                                    .padding(.init(top: 20, leading: 5, bottom: 5, trailing: 1))

                                Text("These processes share the same parent as the proces which made the connection")
                                .padding(2)
                            }
                            
                                ProcessDetailsPeersView(process: self.record.process)
                        }.frame(width: geometry.size.width)
                    }
                }.frame(height: 300, alignment: .center)
            }
        .padding(8)
        }
        .frame(
            minWidth: 600,
            idealWidth: 800,
            maxWidth: .infinity,
            minHeight: 600,
            idealHeight: 600,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

struct RecordDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        (0...1000).forEach { _ in
            let outbound = OpenedConnectionEvent.init(connection: generateTestConnection(direction: .outbound))
            let inbound = OpenedConnectionEvent.init(connection: generateTestConnection(direction: .inbound))
 
            RemoteHistoryCache.shared.eventTriggered(event: outbound)
            ProcessHistoryCache.shared.eventTriggered(event: outbound)
            
            RemoteHistoryCache.shared.eventTriggered(event: inbound)
            ProcessHistoryCache.shared.eventTriggered(event: inbound)
        }

        return RecordDetailsView(connection: generateTestConnection(direction: .inbound))
                    .frame(width: 800, height: 600)
    }
}
