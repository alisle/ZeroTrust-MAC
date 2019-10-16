//
//  RulesView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/7/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct RulesView: View {
    @EnvironmentObject var viewState : ViewState

    var header : some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Zero Trust - Rules")
                    .bold()
            }
            Text("Last updated: \(viewState.rules.updated.toString())")
                .font(.caption)
        }
        .padding()
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
        }.frame(minWidth: 800, maxWidth: .infinity)
    }
}

struct RulesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewState = ViewState()
        viewState.rules = generateTestRules()
        return RulesView().environmentObject(viewState)
    }
}
