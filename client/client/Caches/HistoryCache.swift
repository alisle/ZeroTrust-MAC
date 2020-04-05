//
//  HistoryCache.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/1/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation



class HistoryCache {
    private static let maxDuration : Int = 60 * 60
    
    private let trimQueue = DispatchQueue(label: "com.zerotrust.mac.client.Caches.HistoryCache", attributes: .concurrent)
    private var cache : [String: [Date]] = [:]
    
    init() {
        self.trim()
    }
    
    func trim() {
        self.trimQueue.asyncAfter(deadline: .now() + 60, flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.cache.forEach { (key: String, value: [Date]) in
                self.cache[key] = value.filter{ !$0.olderThan(minutes: HistoryCache.maxDuration / 60) }
            }
            
            self.trim()
        }
    }
    
    func process(key: String, timestamp : Date) {
        var array = cache[key] ?? []
        array.append(Date())
        cache.updateValue(array, forKey: key)
    }
    
    func get(key: String, step : Int, duration: Int) -> [Int]? {
        if duration < 0 || duration > HistoryCache.maxDuration {
            return nil
        }
        
        guard let dates = self.cache[key] else {
            return []
        }
        
        var array = (0..<(duration / step)).map { _ in 0 }
        let currentTimestamp = Date()
        let duration = TimeInterval(duration)
        let floor = currentTimestamp - duration
        
        
        
        dates.forEach { timestamp  in
            if timestamp > floor {
                let distance = floor.distance(to: timestamp)
                let bucket = Int(distance) / step
                array[bucket] += 1
            }
        }
        
        
        return array
    }

}
