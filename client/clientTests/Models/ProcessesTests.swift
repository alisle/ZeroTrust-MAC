//
//  ProcessInfoTests.swift
//  ZeroTrust FWTests
//
//  Created by Alex Lisle on 2/19/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import XCTest

@testable import ZeroTrust_FW

class ProcessesTests : XCTestCase {
    var processes  = Processes()
    
    private func getExampleFile() -> URL {
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        return thisDirectory.appendingPathComponent("HashTestFile.txt")
    }
    
    func testInit() {  
        let info = processes.process(1128)
        XCTAssertNotNil(info)
        var process = info
        
        while process != nil {
            let bundle  = Helpers.getBinaryAppBundle(fullBinaryPath: process?.path)
            
            print("Process: \(process?.description ?? "None")")
            print("Bundle: \(process?.bundle?.displayName ?? "None")")
            print("App Bundle: \(process?.appBundle?.displayName ?? "None")")
            print("From Helper: \(bundle?.displayName ?? "None")")
            
            if let _ = bundle?.icon {
                print("Helper has icon")
            } else {
                print("no icon has been found")
            }
            
            if let _ = process?.bundle?.icon {
                print(" ProcessInfo has icon")
            } else {
                print("no icon has been found")
            }
            
            process = process?.parent
        }
        
    }

    
    func testSHA256() {
        let file = getExampleFile()
        
        let digest = Processes.generateSHA256(path: file.path)
        print("got hash: \(digest!)")
        
        XCTAssertNotNil(digest)
        XCTAssertEqual("d74dc809725d8f2bad0ef0e6c569ab05d86e972446c153a3d6d11f1f654ab1a6", digest!)
    }
    
    func testMD5() {
        let file = getExampleFile()
        let digest = Processes.generateMD5(path: file.path)
        print("got hash: \(digest!)")
        
        XCTAssertNotNil(digest)
        XCTAssertEqual("3a91cd044f33f3ac571a304f91889afb", digest!)

    }
}
