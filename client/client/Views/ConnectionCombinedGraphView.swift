//
//  ConnectionGraphView.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/23/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI


struct ConnectionCombinedGraphView: View {
    var body: some View {
        ZStack {
            ConnectionColouredGraphView()
            ConnectionLineGraphView()
        }
    }
}

struct ConnectionGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let viewState = ViewState()
        
        //viewState.connectionChanged( generateTestConnection(direction: ConnectionDirection.outbound))

        return ConnectionCombinedGraphView().environmentObject(viewState)
    }
}
