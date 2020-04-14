//
//  ConnectionCountsRow.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/14/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionCountsRow: View {
    @EnvironmentObject var connectionCounts : ConnectionCounts
    
    var outbound : some View {
          return Section {
              VStack {
                ConnectionCountView(max: 100, color: Color.green, count: connectionCounts.currentOutboundCount)
                      .animation(nil)
                      .frame(minWidth: 65, idealWidth: 65, maxWidth: 65, minHeight: 65, idealHeight: 65, maxHeight: 65, alignment: .center)
                      .padding(2)
              }
          }
      }
      
      var inbound: some View {
          return Section {
              VStack {
                ConnectionCountView(max: 10, color: Color.red, count: connectionCounts.currentInboundCount)
                      .animation(nil)
                      .frame(minWidth: 65, idealWidth: 65, maxWidth: 65, minHeight: 65, idealHeight: 65, maxHeight: 65, alignment: .center)
                      .padding(2)

              }
          }
      }
      
      var listen: some View {
          return Section {
              VStack {
                  ConnectionCountView(max: 10, color: Color.blue,count: connectionCounts.currentSocketListenCount)
                      .animation(nil)
                      .frame(minWidth: 65, idealWidth: 65, maxWidth: 65, minHeight: 65, idealHeight: 65, maxHeight: 65, alignment: .center)
                      .padding(2)

              }
          }
      }
      
    var body: some View {
        HStack {
            outbound
            inbound
            listen
        }.padding(.init(top: 2, leading: 2, bottom: 2, trailing: 2))
    }
}

struct ConnectionCountsRow_Previews: PreviewProvider {
    static var previews: some View {
        let values = ConnectionCounts()
        values.currentInboundCount = 2
        values.currentOutboundCount = 14
        values.currentSocketListenCount = 20

        return ConnectionCountsRow()
            .environmentObject(values)
    }
}
