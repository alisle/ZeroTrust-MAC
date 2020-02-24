//
//  DNSCache.swift
//  client
//
//  Created by Alex Lisle on 7/29/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

class DNSCache {
    enum RecordType : Int {
        case ARecord = 0,
        CNameRecord = 1,
        QuestionAnsweredRecord = 2
    }
    
    struct Record : Hashable, CustomStringConvertible {
        let type: RecordType
        let url: String
        let ip : IPAddress
        
        init(type: RecordType, url: String, ip: IPAddress) {
            self.type = type
            self.url = url
            self.ip = ip
        }
        
        public var description: String {
            return String("Type:\(type) URL: \(url) IP: \(ip)")
        }
    }
    
    
    private var ARecord2IPs = [String: Set<IPAddress>]()
    private let ARecord2IPsLock = NSLock()
    
    private var Cache = [IPAddress: Record]()
    private let cacheLock = NSLock()
    
    private var ARecord2CNames = [String: Set<String>]()
    private let ARecord2CNamesLock = NSLock()
    
    private var CName2ARecord = [String: String]()
    private let CName2ARecordLock = NSLock()
    
    func update(question: String) {
        checkQuestion(question: question)
    }
    
    private func checkQuestion(question: String) {
        ARecord2IPsLock.lock()
        if let ips = ARecord2IPs[question]  {
            // We have an ARecord which was a question.
            ips.forEach {
                cacheLock.lock()
                Cache[$0] = Record(type:RecordType.QuestionAnsweredRecord, url:question, ip:$0)
                cacheLock.unlock()
            }
        }
        ARecord2IPsLock.unlock()
        
        CName2ARecordLock.lock()
        
        var record : Optional<String> = question
        var searching = true
        while searching {
            record = CName2ARecord[record!]
            if record != nil {
                if ARecord2IPs[record!] != nil {
                    searching = false
                }
            } else {
                // we're done here.
                searching = false
            }
        }
        
        if record != nil {
            if let ips = ARecord2IPs[record!] {
                ips.forEach {
                    cacheLock.lock()
                    Cache[$0] = Record(type:RecordType.QuestionAnsweredRecord, url: question, ip: $0)
                    cacheLock.unlock()
                }
            }
        }
        
        CName2ARecordLock.unlock()
    }
    
    func update(url: String, ip: IPAddress) {
        
        // If it doesn't exist, add it.
        cacheLock.lock()
        if let record =  Cache[ip] {
            if record.type == RecordType.ARecord {
                // Replace it with the new one, else this is a CName, generally keep the CNames as they make more sense.
                Cache[ip] = Record(type: RecordType.ARecord, url: url, ip: ip)
            }
        } else {
            Cache[ip] = Record(type: RecordType.ARecord, url: url, ip: ip)
        }
        cacheLock.unlock()
        
        // Update our list of IPS known for this A Record
        var records : Set<IPAddress> = []
        
        ARecord2IPsLock.lock()
        if let ips = ARecord2IPs[url] {
            records = ips
        }
        records.insert(ip)
        ARecord2IPs[url] = records
        
        ARecord2IPsLock.unlock()
        
        // Check to see if we have any CNames which point to this ARecord.
        checkCName(url: url, ip: ip)
    }
    
    func get(_ ip: IPAddress) -> Optional<String> {
        guard let record = Cache[ip] else {
            return nil
        }
        
        return record.url
    }
    
    private func checkCName(url: String, ip: IPAddress) {
        ARecord2CNamesLock.lock()
        
        if let cNames = ARecord2CNames[url] {
            // See if we have any CNames which point to this URL, if so update our IPs to reflect that.
            if let record = Cache[ip] {
                // We over-write an A Record
                if record.type == RecordType.ARecord {
                    Cache[ip] = Record(type: RecordType.CNameRecord, url: cNames.first!, ip: ip)
                }
            }
        }
                
        ARecord2CNamesLock.unlock()
    }
    
    func update(url: String, cName: String) {
        // Update our ARecord 2 Names.
         var records : Set<String> = []
        
        CName2ARecord[cName] = url
                
        ARecord2CNamesLock.lock()
        if let cNames = ARecord2CNames[url] {
            records = cNames
        }
        records.insert(cName)
        ARecord2CNames[url] = records
        ARecord2CNamesLock.unlock()
        
        ARecord2IPsLock.lock()
        // Update all IPs which pointed to that ARecord to point to the CName instead
        if let ips = ARecord2IPs[url] {
            ips.forEach {
                if let record = Cache[$0] {
                    // If the type is CName, we will keep it.
                    if record.type == RecordType.ARecord {
                        Cache[$0] = Record(type: RecordType.CNameRecord, url: cName, ip: $0)
                    }
                }
            }
        }
        ARecord2IPsLock.unlock()
    }
}
