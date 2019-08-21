//
//  ConnectionDetailsView.swift
//  client
//
//  Created by Alex Lisle on 8/1/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct SiteDetails: View {
    let selected: String
    
    var body: some View {
        VStack {
            Text("Site Details").font(.headline).bold()
            Text("Jerry Love Base")
        }
    }
}
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
        let hstack = HStack() {
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
    
    var protocolDetails: some View {
        let group = VStack(alignment: .leading, spacing: 5) {
            Text("Protocol Details").font(.headline).bold()
            HStack {
                Text("Type:").bold()
                Text("\(connection.portProtocol!.name) - \(connection.portProtocol!.port)")
            }
            
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
            metadata
            Text("I will be a pretty graphic")
                .frame(minWidth: 500, minHeight: 150)

            Spacer()
            if connection.remoteProtocol != nil {
                protocolDetails
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
