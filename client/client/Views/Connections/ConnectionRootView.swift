//
//  Overview.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/4/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI


struct ConnectionRootView: View {
    @EnvironmentObject var connectionCounts : ConnectionCounts
    @EnvironmentObject var locations : Locations
    
    var outbound : some View {
        return Section {
            VStack {
                ConnectionCountView(max: 100, count: connectionCounts.currentOutboundCount)
                    .animation(nil)
                    .frame(minWidth: 65, idealWidth: 65, maxWidth: 65, minHeight: 65, idealHeight: 65, maxHeight: 65, alignment: .center)
                    .padding(.trailing)
            }
        }
    }
    
    var inbound: some View {
        return Section {
            VStack {
                ConnectionCountView(max: 10, count: connectionCounts.currentInboundCount)
                    .animation(nil)
                    .frame(minWidth: 65, idealWidth: 65, maxWidth: 65, minHeight: 65, idealHeight: 65, maxHeight: 65, alignment: .center)
                    .padding(2)

            }
        }
    }
    
    var connectionGraph : some View {
        return Section {
            VStack {
                LineGraph(series: connectionCounts.outboundCounts)
                    .animation(.easeInOut(duration: 0.5))
                    .frame(
                        minWidth: 740,
                        idealWidth: .infinity,
                        maxWidth: .infinity,
                        minHeight: 70,
                        idealHeight: 70,
                        maxHeight: 70,
                        alignment:.center
                    )
            }
        }
    }
    
    var globe : some View {
        Section {
            MapGraph(points: self.locations.points )
        }
        .frame(minWidth: 800, idealWidth: .infinity, maxWidth: .infinity, minHeight: 400, idealHeight: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
    
    var list : some View {
        Section {
            ConnectionList()
        }
        .frame(minWidth: 270, idealWidth: 270, maxWidth: 270, minHeight: 400, idealHeight: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Image("ZTN")
                    .resizable()
                    .frame(width: 128, height: 64, alignment: .center)
                    .padding(.horizontal)
                connectionGraph
                outbound
                inbound

            }
            
            
            // Middle
            HStack {
                list
                globe
            }
            .padding(.init(top: 2, leading: 2, bottom: 25, trailing: 2))
        }
    }
}

struct Overview_Previews: PreviewProvider {
    static var previews: some View {
        let values = ConnectionCounts()
        values.currentInboundCount = 2
        values.currentOutboundCount = 14
        values.outboundCounts = (0..<10).map{ _ in CGFloat.random(in: 0...20) }
        
        
        let allConnections = AllConnections()
             allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
             allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
             allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
             allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
             allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
             allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
             allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
             allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
             allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
             allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
             allConnections.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))

        return ConnectionRootView()
            .environmentObject(values)
            .environmentObject(Locations())
            .environmentObject(allConnections)
    }
    
}

