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
/*
    private func convert(_ counts: [String : Int]) -> [GlobeMapCountry] {
        var countries : [GlobeMapCountry] = []
        counts.forEach { iso, count in
            if let feature = self.viewState.geomap.iso[iso] {
                countries.append(feature)
            }
        }
        
        return countries
    }
*/
    
    var body: some View {
        VStack{
            ZStack {
                /*
                GlobeShape(countries: )
                    .fill(Color.black)
                
                GlobeShape()
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
                GlobeShape() // countries: self.viewState.counts)
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
                 */
                
                Text("Testing")
            }.drawingGroup()
            .frame(minWidth: 1000, minHeight: 500)
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
        
        viewState.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        viewState.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        viewState.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        viewState.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        viewState.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
        viewState.eventTriggered(event: ConnectionChangedEvent(connection: generateTestConnection(direction: ConnectionDirection.outbound)))
                
        return ConnectionCombinedGraphView().environmentObject(viewState)
    }
}
