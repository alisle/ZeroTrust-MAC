//
//  ProcessDetailsCallTree.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/1/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI


struct BundleView: View {
    let bundle : Bundle
    let image : NSImage?
    let size : CGSize
    
    init(bundle : Bundle, size : CGSize = .init(width: 64, height: 64)) {
        self.image = bundle.icon
        self.bundle = bundle
        self.size = size
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            if self.image == nil {
                Image("Console")
                    .resizable()
                    .frame(width: size.width, height: size.height, alignment: .center)
            } else {
                Image(nsImage: self.image!)
                    .resizable()
                    .frame(width: size.width, height: size.height, alignment: .center)
            }
        }
    }
}

struct CommandLineView: View {
    let command : String
    let size : CGSize
    
    init(command : String, size : CGSize = .init(width: 64, height: 64)) {
        self.command = command
        self.size = size
    }
    var body: some View {
        VStack {
            Image("Console")
                .resizable()
                .frame(width: size.width, height: size.height, alignment: .center)
        }
    }
}

struct ProcessDetailsCallTree: View {
    let process : ProcessDetails
    let processes : [ProcessDetails]
    
    init(process : ProcessDetails) {
        var list : [ProcessDetails] = []
        var current : ProcessDetails? = process
        
        list.append(process)
        while(current != nil) {
            list.append(current!)
            current = current?.parent
        }
        
        self.processes = list.reversed()
        self.process = process
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List(content: {
                    ForEach(self.processes) { proc in
                        NavigationLink(destination: ProcessDetailsView(process: proc)) {
                            HStack {
                                if proc.appBundle != nil {
                                    BundleView(bundle: proc.appBundle!, size: .init(width: 32, height: 32))
                                } else {
                                    CommandLineView(command: proc.command!, size: .init(width: 32, height: 32))
                                }
                                Text("\(proc.command!)").bold()
                                Spacer()
                            }
                        }
                    }
                })
                .listStyle(SidebarListStyle())
                .frame(minWidth: 150, idealWidth: 180, maxWidth: .infinity, alignment: .leading)

                EmptyView()
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
    }
}

struct ProcessDetailsView: View {
    let process : ProcessDetails
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .stroke(Color.white, lineWidth: 1)
                        
                VStack {
                    HStack {
                        Text("\(self.process.command!)")
                            .bold()
                            .padding(3)
                        Spacer()
                    }
                    .foregroundColor(Color.black)
                    .background(Color.white)

                    HStack(alignment: .top, spacing: 2) {
                        HStack {                            
                            if process.appBundle != nil {
                                BundleView(bundle: process.appBundle!)
                            } else {
                                CommandLineView(command: process.command!)
                            }
                        }.padding(.init(top: 1, leading: 5, bottom: 1, trailing: 3))

                        VStack(alignment: .leading, spacing: 2) {
                            if process.path != nil {
                                Text("Path: \(process.path!)")
                            }
                            
                            Text("PID: \(String(process.pid))")
                            Text("PPID: \(String(process.ppid))")
                            if process.username != nil {
                                Text("Process Owner: \(process.username!)(\(String(process.uid!)))")
                            }
                            
                            if process.sha256 != nil {
                                Text("SHA256: \(process.sha256!)")
                            }
                            
                            if process.md5 != nil {
                                Text("MD5: \(process.md5!)")
                            }
                            Spacer()
                        }.padding(.init(top: 1, leading: 5, bottom: 5, trailing: 1))
                        Spacer()
                    }
                }
            }.padding(5)
        }
    }

}

struct ProcessDetailsPeersView: View {
    let process : ProcessDetails
    let hasNoPeers : Bool
    let hasParent : Bool
    let peers : [ProcessDetails]
    
    init(process: ProcessDetails) {
        let peers = (process.hasPeers) ? process.peers! : []
            .filter{ $0.pid != process.pid }
            .sorted{ lhs, rhs in lhs.pid > rhs.pid }
        
        let hasNoPeers = peers.count == 0
        
        self.process = process
        self.hasNoPeers = hasNoPeers
        self.hasParent = process.parent != nil
        self.peers = peers
    }
    
    var noParentView : some View {
        VStack {
            Text("Process has no parent")
                .bold()
                .font(.subheadline)
        }
    }
    
    var noPeersView : some View {
        VStack {
            Text("Process has no peers")
                .bold()
                .font(.subheadline)
        }
    }
    
    var multiplePeers : some View {
        GeometryReader { geometry in
            NavigationView {
                List(content: {
                    ForEach(self.peers) { proc in
                        NavigationLink(destination: ProcessDetailsView(process: proc)) {
                            HStack {
                                if proc.appBundle != nil {
                                    BundleView(bundle: proc.appBundle!, size: .init(width: 32, height: 32))
                                } else {
                                    CommandLineView(command: proc.command!, size: .init(width: 32, height: 32))
                                }
                                Text("\(proc.command!)").bold()
                                Spacer()
                            }
                        }
                    }
                })
                .listStyle(SidebarListStyle())
                .frame(minWidth: 150, idealWidth: 180, maxWidth: .infinity, alignment: .leading)
                
                EmptyView()
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
    }
    
    var body: some View {
        VStack {
            if !self.hasParent {
                noParentView
            } else {
                if self.hasNoPeers {
                    noPeersView
                } else {
                    multiplePeers
                }
            }
        }
    }


}

struct ProcessDetailsCallTree_Previews: PreviewProvider {
    static var previews: some View {
        let manager = ProcessManager()
        let bundle = manager.getAppBundle(path: "/Applications/Google Chrome.app")
        
        let stack = VStack {
            HStack {
                Text("Bundle View ")
                BundleView(bundle: bundle!)
                Text("CommandLine View ")
                CommandLineView(command: "/usr/bin/ssh")
            }
            VStack {
                Text("Process Details View")
                ProcessDetailsView(process: generateProcessInfo())
                Text("Process Call Tree ")
                ProcessDetailsCallTree(process: generateProcessInfo(true, 9))
            }
            VStack {
                Text("ProcessDetailsPeersView No Parent")
                ProcessDetailsPeersView(process: generateProcessInfo(false))
                
                Text("ProcessDetailsPeersView One Peer")
                ProcessDetailsPeersView(process: generateProcessInfo(true, 1))
            
                Text("ProcessDetailsPeersView Multiple Peer")
                ProcessDetailsPeersView(process: generateProcessInfo(true, 9))
            }

        }
        .frame(width: 800, alignment: .center)
        
        return stack
    }
}
