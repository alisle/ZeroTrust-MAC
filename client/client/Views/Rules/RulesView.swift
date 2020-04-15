//
//  RulesView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/7/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct RulesView: View {
    @EnvironmentObject var rules : AllRules

    var header : some View {
        VStack(alignment: .leading) {
            Header()
            Text("Last updated: \(rules.rules.updated.toString())")
                .font(.caption)
                .padding(.init(top: 1, leading: 20, bottom: 1, trailing: 1))
        }
    }

    var rulesContainer : some View {
        NavigationView {
            RulesListView()
                .frame(minWidth: 400, maxWidth: 600)
            
            Text("Please Select a Rule")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            header
            rulesContainer
        }
    }
}

struct RulesView_Previews: PreviewProvider {
    static var previews: some View {
        let allRules = AllRules(rules: Rules.load())
        
        let values = ConnectionCounts()
        values.currentInboundCount = 2
        values.currentOutboundCount = 14
        values.currentSocketListenCount = 20
        values.outboundCounts = (0..<10).map{ _ in CGFloat.random(in: 0...20) }

        return RulesView()
            .environmentObject(allRules)
            .environmentObject(EnabledServices())
            .environmentObject(ConnectionCounts())
            .environmentObject(Locations())
            .environmentObject(AllConnections())
            .environmentObject(Queries())
            .environmentObject(AllListens())
    }
}
