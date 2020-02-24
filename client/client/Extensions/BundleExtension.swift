//
//  BundleExtension.swift
//  client
//
//  Created by Alex Lisle on 6/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import AppKit

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
    
    
    
    var icon: Optional<NSImage> {
        guard let dictionary = self.infoDictionary else {
            return Optional.none
        }
        
        guard let fullIconFile = dictionary["CFBundleIconFile"] as? String else {
            return Optional.none
        }

        var iconType = "icns"
        var iconFile = fullIconFile
        
        if let index = fullIconFile.lastIndex(of: (".")) {
            iconFile = String(fullIconFile[...index].dropLast())
            iconType = String(fullIconFile[index...].dropFirst())
        }
        guard let iconPath = self.path(forResource: iconFile, ofType: iconType) else {
            return Optional.none
        }
        return NSImage(byReferencingFile: iconPath)

    }
}
