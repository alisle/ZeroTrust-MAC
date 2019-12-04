//
//  ConnectionGraphView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/23/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionCombinedGraphView: View {
    @EnvironmentObject var viewState : ViewState

    private func convert(_ counts: [String : Int]) -> [GraphCountry] {
        var countries : [GraphCountry] = []
        counts.forEach { iso, count in
            if let feature = self.viewState.geomap.iso[iso] {
                countries.append(feature)
            }
        }
        
        return countries
    }

    var body: some View {
        VStack{
            ZStack {
                GlobeGraph(countries: viewState.geomap.countries)
                    .fill(Color.black)

                GlobeGraph(countries: viewState.geomap.countries)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(
                                colors: [
                                    .red,
                                    .yellow,
                                    .green,
                                    .blue,
                                    .purple,
                                    .red
                            ]),
                            center: .center
                        )
                )
                
                GlobeGraph(countries: self.viewState.counts)
                    .fill(
                        AngularGradient(
                            gradient: Gradient(
                                colors: [
                                    .red,
                                    .yellow,
                                    .green,
                                    .blue,
                                    .purple,
                                    .red
                            ]),
                            center: .center
                        )
                    )
                ConnectionAmountShape(counts: viewState.amountsOverHour)
                    .fill(Color.yellow)
            }
            .frame(minWidth: 1000, minHeight: 500)
            .drawingGroup()
            
            HStack(alignment: .bottom) {
                ForEach(viewState.lastConnections.reversed()) { connection in
                    GlobeCapsuleView(connection: connection)
                }
            }.frame(minHeight: 64)
             
        }
    }
}

struct ConnectionGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let viewState = ViewState()
        
        viewState.connectionChanged( generateTestConnection(direction: ConnectionDirection.outbound))
        
        viewState.connectionChanged( generateTestConnection(direction: ConnectionDirection.outbound))
        
        viewState.connectionChanged( generateTestConnection(direction: ConnectionDirection.outbound))
        
        viewState.connectionChanged( generateTestConnection(direction: ConnectionDirection.outbound))
        
        viewState.connectionChanged( generateTestConnection(direction: ConnectionDirection.outbound))
        
        
        return ConnectionCombinedGraphView().environmentObject(viewState)
    }
}
