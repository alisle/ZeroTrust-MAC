//
//  Preferences.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/1/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

struct Preferences: Codable {
    var rulesUpdateURL : String
    var rulesUpdateInterval : Int
    
    static func load() -> Optional<Preferences> {
        if let path = Bundle.main.path(forResource: "preferences", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path),
            let preferences = try? PropertyListDecoder().decode(Preferences.self, from: xml)
        {
                return preferences
        }
        
        return nil
    }
    
    
}
