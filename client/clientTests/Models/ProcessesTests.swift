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
    let processManager = ProcessManager()
    
    private func getExampleFile() -> URL {
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        return thisDirectory.appendingPathComponent("HashTestFile.txt")
    }
    
    func testInit() {  
        let info = processManager.get(pid: 1128)
        XCTAssertNotNil(info)
        var process = info
        
        while process != nil {
            print("Process: \(process?.description ?? "None")")
            print("Bundle: \(process?.bundle?.displayName ?? "None")")
            print("App Bundle: \(process?.appBundle?.displayName ?? "None")")
            print("SHA256: \(process?.sha256 ?? "None")")
            print("MD5: \(process?.md5 ?? "None")")
                        
            process = process?.parent
        }
        
    }

    func testGetChildren() {
        let children = processManager.getChildren(pid: 1)
        XCTAssertFalse(children.isEmpty)
        
        print("I have children! \(children)")
    }
    
    func testListChildren() {
        let children = processManager.listChildren(pid: 1)
        XCTAssertFalse(children.isEmpty)
        
        print("I have children! \(children)")
    }
    
    func testSHA256() {
        let file = getExampleFile()
        
        let digest = processManager.generateSHA256(path: file.path)
        print("got hash: \(digest!)")
        
        XCTAssertNotNil(digest)
        XCTAssertEqual("d74dc809725d8f2bad0ef0e6c569ab05d86e972446c153a3d6d11f1f654ab1a6", digest!)
    }
    
    func testMD5() {
        let file = getExampleFile()
        let digest = processManager.generateMD5(path: file.path)
        print("got hash: \(digest!)")
        
        XCTAssertNotNil(digest)
        XCTAssertEqual("3a91cd044f33f3ac571a304f91889afb", digest!)

    }
}
