//
//  ConnectionDetailsDirectionBanner.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 3/30/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ConnectionDirectionIcon: View {
    let direction : ConnectionDirection
    let size : CGFloat
    
    init(direction: ConnectionDirection, size: CGFloat = 64)  {
        self.direction = direction
        self.size = size
    }
    
    var text : String {
        get {
            switch direction {
            case .inbound:
                return "InboundArrow"
            default:
                return "OutboundArrow"
            }
        }
    }
    
    var body: some View {
        Image(self.text)
            .resizable()
            .frame(width: size, height: size, alignment: .trailing)
    }
}

struct ConnectionDetailsDirectionBanner_Previews: PreviewProvider {
    static var previews: some View {
        return VStack {
            ConnectionDirectionIcon(direction: .inbound)
            Spacer()
            ConnectionDirectionIcon(direction: .outbound)
            Spacer()
            ConnectionDirectionIcon(direction: .inbound, size: 32)
            Spacer()
            ConnectionDirectionIcon(direction: .outbound, size: 16)
        }
    }
}
