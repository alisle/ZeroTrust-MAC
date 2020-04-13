//
//  ConnectionIcon.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/22/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI


struct ProcessDetailsIcon: View {
    let processInfo : ProcessDetails
    let size : CGFloat
     var body: some View {
         Group() {
             if processInfo.image == nil {
                 Image("Console")
                    .resizable()
                    .frame(width: size, height: size, alignment: .leading)
             } else {
                 Image(nsImage: processInfo.image!)
                    .resizable()
                    .frame(width: size, height: size, alignment: .leading)
             }
         }
     }
    
}

#if DEBUG
struct ConnectionIcon_Previews: PreviewProvider {
    static var previews: some View {
        ProcessDetailsIcon(processInfo: generateProcessInfo(), size: 64)
    }
}
#endif
