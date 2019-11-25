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

    private func convert(_ counts: [String : Int]) -> [GeoCountry] {
        var countries : [GeoCountry] = []
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
                GlobeShape(map: viewState.geomap.features)
                    .fill(Color.black)
                
                GlobeShape(map: viewState.geomap.features)
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

                GlobeShape(map: self.viewState.counts)
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
            .frame( minWidth: 800, minHeight: 300)
            
            HStack(alignment: .bottom) {
                ForEach(viewState.lastConnections.reversed()) { connection in
                    GlobeCapsuleView(connection: connection)
                }
            }
             
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
