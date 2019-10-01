//
//  PreferencesTests.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 10/1/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import XCTest
@testable import ZeroTrust_FW

class PreferencesTests : XCTestCase {
    
    func testLoadPreferences() {
        XCTAssertNotNil(Preferences.load())
    }
 
    func testRulesURL() {
        let pref = Preferences.load()!
        let url = URL(string: pref.rulesUpdateURL)
        
        XCTAssertNotNil(url)
    }
}
