//
//  InspectRootView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/20/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

enum DecisionUserChoices : String, CaseIterable {
    case AllowAllOutboundProcess = "Allow all connections from this process"
    case AllowAllOutboundPID = "Allow all connections from this process instance"
    case AllowAllHost = "Allow all connections to this host"
    case AllowAllHostPort = "Allow all connections to this port on this host"
    case AllowOneTime = "Allow this particular connection"
    case Block = "Reject this connection"
}

struct InspectRootView: View {
    @EnvironmentObject var queries : Queries
        
    var body: some View {
        List() {
            ForEach(Array(queries.needsInput), id: \.tag) { query in
                DecisionDetails(query: query)
            }
        }
    }
}

struct DecisionDetails : View {
    let query : FirewallQuery
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            DetailsHeader(record: query)
            VStack(alignment: .leading, spacing: 1.0) {
                Text("Connection Overview")
                    .font(.subheadline)
                    .bold()
                
                UserChain(record: query)
                .padding()
            }
            
            VStack(alignment: .leading, spacing: 1.0) {
                Text("Process Making Connection")
                    .font(.subheadline)
                    .bold()

                ProcessDetailsView(process: query.process)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Protocol Details")
                        .font(.subheadline)
                        .bold()

                    ProtocolDetailsView(record: self.query)
                }
                .frame(height: 200, alignment: .center)
                        
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Location Details")
                        .font(.subheadline)
                        .bold()
                    LocationDetails(location: self.query.location)
                    Spacer()
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
                                       
                        ProcessDetailsCallTree(process: self.query.process)
                    }.frame(width: geometry.size.width)
                }
            }.frame(height: 300, alignment: .center)
            
            
        }
    }
}

struct DecisionSelection: View {
    @State private var selected = DecisionUserChoices.Block
    
    var body: some View {
        VStack {
             Picker(selection: $selected, label: Text("Please choose")) {
                ForEach(DecisionUserChoices.allCases, id: \.self) {
                    Text("\($0.rawValue)")
                }
             }
            
            Text("You selected: \(selected.rawValue)")
        }
    }
}

struct InspectRootView_Previews: PreviewProvider {
    static var previews: some View {
        /*
        let queries = Queries()
        
        (0...100).forEach { _ in
            EventManager.shared.triggerEvent(event: DecisionNeedsInputEvent(query: generateFirewallQuery()))
        }
         */
        
        return VStack {
            Text("Decision Selection")
            DecisionSelection()
            Spacer()
            Text("Decision Details")
            DecisionDetails(query: generateFirewallQuery())
                .frame(width: 800, height: 600)
            Spacer()
        }
    }
}
