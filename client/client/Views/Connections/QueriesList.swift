//
//  PendingQueriesList.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/9/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct DecisionsList: View {
    @EnvironmentObject var queries : Queries
    
    var body: some View {        
        List() {
            ForEach(queries.maadeDecisions, id: \.0.tag) { query in
                HStack {
                    Text("\(query.1.description) - \(query.0.description)")
                        .font(.system(size: 10, design: .monospaced))
                    Spacer()
                }.listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }.listStyle(PlainListStyle())
    }
}

struct PendingQueriesList: View {
    @EnvironmentObject var queries : Queries
    
    var body: some View {
        List() {
            ForEach(Array(queries.pendingQueries), id: \.tag) { query in
                HStack {
                    Text("\(query.description)")
                        .font(.system(size: 10, design: .monospaced))
                    Spacer()                    
                }
            }
        }.listStyle(PlainListStyle())
        
    }
}

struct PendingQueriesList_Previews: PreviewProvider {
    static var previews: some View {
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

        return VStack {
            PendingQueriesList()
            Spacer()
            DecisionsList()
        }.environmentObject(queries)
    }
}
