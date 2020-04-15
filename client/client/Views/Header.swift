//
//  Header.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/15/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct Header: View {
    @EnvironmentObject var connectionCounts : ConnectionCounts
    @EnvironmentObject var services : EnabledServices

    var disabledFlag : some View {
        HStack {
            Text("Firewall Disabled")
                .padding(.init(top: 1, leading: 20, bottom: 1, trailing: 20))
            Spacer()
        }
        .background(Color.red)
        .foregroundColor(Color.black)
        .padding(.init(top: 1, leading: 5, bottom: 1, trailing: 5))
    }
    
    var denyModeFlag : some View {
        HStack {
            Text("Deny Mode Enabled")
                .padding(.init(top: 1, leading: 20, bottom: 1, trailing: 20))
            Spacer()
        }
        .background(Color.yellow)
        .foregroundColor(Color.black)
        .padding(.init(top: 1, leading: 5, bottom: 1, trailing: 5))
    }
    
    var inspectModeFlag : some View {
        HStack {
            Text("Inspect Mode Enabled")
                .padding(.init(top: 1, leading: 20, bottom: 1, trailing: 20))
            Spacer()
        }
        .background(Color.green)
        .foregroundColor(Color.black)
        .padding(.init(top: 1, leading: 5, bottom: 1, trailing: 5))

    }
    
    var connectionGraph : some View {
        return Section {
            VStack {
                LineGraph(series: connectionCounts.outboundCounts)
                    .animation(.easeInOut(duration: 0.5))
                    .frame(
                        minWidth: 740,
                        idealWidth: .infinity,
                        maxWidth: .infinity,
                        minHeight: 70,
                        idealHeight: 70,
                        maxHeight: 70,
                        alignment:.center
                    )
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image("ZTN")
                    .resizable()
                    .frame(width: 128, height: 64, alignment: .center)
                    .padding(.horizontal)
                connectionGraph
                ConnectionCountsRow()
                
            }
            
            if !services.enabled {
                self.disabledFlag
            } else if services.denyMode {
                self.denyModeFlag
            } else if services.inspectMode {
                inspectModeFlag
            }
        }
        .padding(.init(top: 0, leading: 0, bottom: 5, trailing: 10))

    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        
        
        let values = ConnectionCounts()
        values.currentInboundCount = 2
        values.currentOutboundCount = 14
        values.currentSocketListenCount = 20
        values.outboundCounts = (0..<10).map{ _ in CGFloat.random(in: 0...20) }

        let services = EnabledServices()
        
        return Header()
            .environmentObject(values)
            .environmentObject(services)
    }
}
