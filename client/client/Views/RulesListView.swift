//
//  RulesListView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/15/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct RulesListView: View {
    @EnvironmentObject var viewState : ViewState
    
    var body: some View {
        List {
            Section(header: Text("Rules")) {
                ForEach(Array(viewState.rules.getSortedMetadata())) { metadata in
                    NavigationLink(destination: RulesDetailView(rule: metadata).environmentObject(self.viewState)) {
                        Text(metadata.name)
                    }
                }
            }
        }.listStyle(SidebarListStyle())
    }
}

struct RulesListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewState = ViewState()
        viewState.rules = generateTestRules()
        return RulesListView().environmentObject(viewState)
    }
}
