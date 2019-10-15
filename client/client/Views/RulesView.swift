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
        HStack {
            Text("Zero Trust - Rules").bold()
            Spacer()
        }
    }

    var body: some View {
        VStack {
            header
            HStack {
                List {
                    Section(header: Text("Rules")) {
                        ForEach(Array(viewState.rules.metadata.values)) { metadata in
                            HStack {
                                Text(metadata.name)
                            }
                        }
                    }
                }.listStyle(SidebarListStyle())
            }
        }
    
    }
}

struct RulesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewState = ViewState()
        viewState.rules = generateTestRules()
        return RulesView().environmentObject(viewState)
    }
}
