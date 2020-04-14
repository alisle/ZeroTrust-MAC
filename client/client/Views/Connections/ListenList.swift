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
                            Text("\(listen.process.command!)")
                                .bold()
                            HStack {
                                Text("PID:\(String(listen.process.pid))")
                                Spacer()
                                Text("Port:\(String(listen.localSocket.portDescription))")
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
