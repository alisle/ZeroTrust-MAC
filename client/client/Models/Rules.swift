//
//  Rules.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 9/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation


struct RulesEntry : Codable, Identifiable, Comparable {
    var indicator : String
    var meta_id : String
    
    var id : String {
        get { self.meta_id }
    }
    
    static func < (lhs: RulesEntry, rhs: RulesEntry) -> Bool {
        return lhs.indicator < rhs.indicator
    }
    
}

struct RulesMetaData : Identifiable {
    var id : String
    var created : Date
    var description : String
    var name : String
    var references : [URL]
    
}

struct Rules  {
    var domains : [RulesEntry]
    var hostnames : [RulesEntry]
    var metadata: [String: RulesMetaData]
    var updated : Date = Date()
    
    func getHostnames(metaId: String) -> [String] {
        return hostnames.filter { $0.meta_id == metaId }.map { $0.indicator }
    }
    
    func getDomains(metaId: String) -> [String] {
        return domains.filter { $0.meta_id == metaId }.map { $0.indicator }
    }
    
    func getSortedMetadata() -> [RulesMetaData] {
        return self.metadata.values.sorted(by: { lhs, rhs in
            switch lhs.name.compare(rhs.name) {
            case .orderedAscending: return true
            case .orderedDescending: return false
            case .orderedSame: return false
            }
        })
    }
}


struct JSONRulesMetadata : Codable {
    var id : String
    var created : String
    var description : String
    var name: String
    var references : [String]
    
}

struct JSONRules : Codable {
    var domains: [RulesEntry]
    var hostnames: [RulesEntry]
    var metadata : [JSONRulesMetadata]
        
    func convert() -> Rules {
        var dictionary : [ String: RulesMetaData] = [:]
        let formatter = DateFormatter()
        
        // Example: 2018-05-23T19:36:47.037000
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        metadata.forEach {
            let id = $0.id
            
            
            let startIndex = $0.created.startIndex
            let endIndex = $0.created.index(startIndex, offsetBy: formatter.dateFormat.count - 2)
            let dateString = String($0.created[startIndex..<endIndex])
            let created = formatter.date(from: dateString)!
            
            
            
            let description = $0.description
            let name = $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var references : [URL] = []
            $0.references.forEach { ref in
                if let url = URL(string: ref) {
                    references.append(url)
                }
            }
            
            let entry = RulesMetaData(
                id: id,
                created: created,
                description: description,
                name: name,
                references: references
            )
            
            dictionary[id] = entry
        }
        
        
        return Rules( domains: self.domains, hostnames: self.hostnames, metadata: dictionary)
    }

}




