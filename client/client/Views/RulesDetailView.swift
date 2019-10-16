//
//  RulesDetailView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/15/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct RulesDetailView: View {
    @EnvironmentObject var viewState : ViewState
    let rule: RulesMetaData
    
    var title: some View {
        let hstack = HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(rule.name)
                    .font(.title)
                    .bold()
                
                Text("Created \(rule.created.toString())")
                    .font(.caption)
                    .opacity(0.75)
            }
            
        }
        
        return hstack.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
    }

    var description: some View {
        VStack(alignment: .leading) {
            Text("Description")
                .font(.subheadline)
                .bold()
            
            if rule.description.isEmpty {
                Text("No Description.")
            } else {
                Text(rule.description)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .frame(minWidth: 500,
                           maxWidth: .infinity,
                           minHeight: 50,
                           idealHeight: 100,
                           maxHeight: .infinity,
                           alignment: .topLeading)

            }
        }
    }
    
    var references: some View {
        VStack(alignment: .leading){
            Text("References")
                .font(.subheadline)
                .bold()
            
            ForEach(rule.references) { reference in
                Text(reference.absoluteString)
            }
        }
    }
    
    var ioc: some View {
        VStack(alignment: .leading) {
            Text("Indicators")
                .font(.subheadline)
                .bold()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Hostnames")
                        .bold()
                        .padding(2)
                    ForEach(viewState.rules.getHostnames(metaId: rule.id), id: \.self) { hostname in
                        Text(hostname)
                    }
                }.padding()
                Spacer()
                VStack(alignment: .leading) {
                    Text("Domains")
                        .bold()
                        .padding(2)
                    
                    ForEach(viewState.rules.getDomains(metaId: rule.id), id: \.self) { domain in
                        Text(domain)
                    }

                }.padding()
            }
        }
    }
    var body: some View {
        List {
            title
            description
            references
            ioc
            
        }
    }
}

struct RulesDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewState = ViewState()
        viewState.rules = generateTestRules()
        
        return RulesDetailView(rule: viewState.rules.metadata.first!.value).environmentObject(viewState)
    }
}
