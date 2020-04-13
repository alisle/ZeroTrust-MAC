//
//  ListenList.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/13/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ListenList: View {
    @EnvironmentObject var listens : AllListens
    
    var body: some View {
        List(content: {
            Text("Process Listening on Ports")
                .font(.subheadline)

            if self.listens.listens.count == 0 {
                Text("Empty.")
            } else {
                ForEach(self.listens.listens, id: \.tag) { listen in
                    HStack {
                        ProcessDetailsIcon(processInfo: listen.process, size: 32)
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(listen.process.command!)")
                                    .bold()
                                    .padding(3)
                                Spacer()
                                Text("\(String(listen.localSocket.port))")
                            }
                        }
                    }
                }
            }
        })
        .listStyle(SidebarListStyle())
    }
}

struct ListenList_Previews: PreviewProvider {
    static var previews: some View {
        let listens = AllListens()
        
        listens.eventTriggered(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        listens.eventTriggered(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        listens.eventTriggered(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        listens.eventTriggered(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        listens.eventTriggered(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        listens.eventTriggered(event: ListenStartedEvent(listen: generateFirewallSocketListen()))
        listens.eventTriggered(event: ListenStartedEvent(listen: generateFirewallSocketListen()))


        return ListenList().environmentObject(listens)
    }
}
