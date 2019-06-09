//
//  BundleExtensions.swift
//  reporter
//
//  Created by Alex Lisle on 6/8/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

extension Bundle {
    var displayName: Optional<String> {
        guard let dictionary = self.infoDictionary else {
            return Optional.none
        }
        
        if let version : String = dictionary["CFBundleName"] as? String {
            return Optional(version)
        }
        
        return Optional.none
    }
}
