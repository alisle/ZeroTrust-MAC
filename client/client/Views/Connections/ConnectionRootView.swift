//
//  Overview.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/4/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI


struct ConnectionRootView: View {
    @EnvironmentObject var locations : Locations
    
  

    var globe : some View {
        Section {
            MapGraph(points: self.locations.points )
        }
        .frame(minWidth: 800, idealWidth: .infinity, maxWidth: .infinity, minHeight: 600, idealHeight: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    var outboundList : some View {
        Section {
            ConnectionList(direction: .outbound)
        }
        .frame(minWidth: 270, idealWidth: 270, maxWidth: 270, minHeight: 400, idealHeight: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    var inboundList : some View {
        Section {
            ConnectionList(direction: .inbound)
        }
        .frame(minWidth: 270, idealWidth: 270, maxWidth: 270, minHeight: 200, idealHeight: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    var listenList : some View {
        Section {
            ListenList()
        }
        .frame(minWidth: 270, idealWidth: 270, maxWidth: 270, minHeight: 200, idealHeight: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    var body: some View {
        VStack {
            Header()            
            // Middle
            HStack {
                outboundList
                globe
                VStack(spacing: 0.0) {
                    self.listenList
                    self.inboundList
                }
                .frame(minWidth: 270, idealWidth: 270, maxWidth: 270, minHeight: 400, idealHeight: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .padding(.init(top: 2, leading: 2, bottom: 2, trailing: 2))

            HStack {
                VStack(alignment: .leading, spacing: 1.4) {
                    Text("Pending Decisions")
                        .padding(.init(top: 1, leading: 5, bottom: 1, trailing: 1))
                    PendingQueriesList()
                }
                
                VStack(alignment: .leading, spacing: 1.4) {
                    Text("Made Decisions")
                        .padding(.init(top: 1, leading: 5, bottom: 1, trailing: 1))
                    DecisionsList()
                }
            }
            .padding(.init(top: 0, leading: 0, bottom: 5, trailing: 2))
            .frame(minWidth: 400, idealWidth: .infinity, maxWidth: .infinity, minHeight: 100, idealHeight: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct Overview_Previews: PreviewProvider {
    static var previews: some View {
        let values = ConnectionCounts()
        values.currentInboundCount = 2
        values.currentOutboundCount = 14
        values.currentSocketListenCount = 20
        values.outboundCounts = (0..<10).map{ _ in CGFloat.random(in: 0...20) }
        
        let listens = AllListens()
        EventManager.shared.triggerEvent(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        EventManager.shared.triggerEvent(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        EventManager.shared.triggerEvent(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        EventManager.shared.triggerEvent(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        EventManager.shared.triggerEvent(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        EventManager.shared.triggerEvent(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        EventManager.shared.triggerEvent(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        
        let queries = Queries()
        EventManager.shared.triggerEvent(event: DecisionQueryEvent(query: generateFirewallQuery()))
        EventManager.shared.triggerEvent(event: DecisionQueryEvent(query: generateFirewallQuery()))
        EventManager.shared.triggerEvent(event: DecisionQueryEvent(query: generateFirewallQuery()))
        EventManager.shared.triggerEvent(event: DecisionQueryEvent(query: generateFirewallQuery()))
        EventManager.shared.triggerEvent(event: DecisionQueryEvent(query: generateFirewallQuery()))
        EventManager.shared.triggerEvent(event: DecisionQueryEvent(query: generateFirewallQuery()))
        
        
        EventManager.shared.triggerEvent(event: DecisionMadeEvent(query: generateFirewallQuery(), decision: .allowed))
        EventManager.shared.triggerEvent(event: DecisionMadeEvent(query: generateFirewallQuery(), decision: .allowed))
        EventManager.shared.triggerEvent(event: DecisionMadeEvent(query: generateFirewallQuery(), decision: .allowed))
        EventManager.shared.triggerEvent(event: DecisionMadeEvent(query: generateFirewallQuery(), decision: .blocked))
        EventManager.shared.triggerEvent(event: DecisionMadeEvent(query: generateFirewallQuery(), decision: .allowed))
        EventManager.shared.triggerEvent(event: DecisionMadeEvent(query: generateFirewallQuery(), decision: .blocked))
        
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
            .environmentObject(queries)
            .environmentObject(listens)
    }
    
}

