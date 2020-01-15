//
//  ConnectionsViewHeader.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 1/14/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionsViewHeader: View {
    @EnvironmentObject var viewState : ViewState

    var body : some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Zero Trust - Connections -- This is the header")
                    .bold()
            }
        }
        .padding()
    }
}

struct ConnectionsViewHeader_Previews: PreviewProvider {
    static var previews: some View {
        let viewState = ViewState( aliveConnections: [], deadConnections:  [])
        return ConnectionsViewHeader().environmentObject(viewState)
    }
}
