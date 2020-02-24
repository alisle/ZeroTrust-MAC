//
//  URLExtension.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/16/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import Logging
import CommonCrypto

extension URL : Identifiable {
        
    public var id : String {
        get { self.absoluteString }
    }
    
}

