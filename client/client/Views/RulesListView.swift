//
//  RulesListView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/15/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct RulesListView: View {
    @EnvironmentObject var allRules : AllRules
    
    var body: some View {
        List {
            Section(header: Text("Rules")) {
                ForEach(Array(allRules.rules.getSortedMetadata())) { metadata in
                    NavigationLink(destination: RulesDetailView(rule: metadata)) {
                        Text(metadata.name)
                    }
                }
            }
        }.listStyle(SidebarListStyle())
    }
}

struct RulesListView_Previews: PreviewProvider {
    static var previews: some View {
        let allRules = AllRules(rules: Rules.load())
        return RulesListView().environmentObject(allRules)
    }
}
