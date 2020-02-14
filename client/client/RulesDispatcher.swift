//
//  RulesDispatcher.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 9/30/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation
import Logging

typealias QueryResult = (Rules?, String) -> Void

class RulesDispatcher {
    let logger = Logger(label: "com.zerotrust.client.RulesDispatcher")

    let url : Optional<URL>
    let session = URLSession(configuration: .default)
    
    var task : URLSessionDataTask?
    var hasError = false
    var errorMessage : Optional<String> = nil
    
    init() {
        let preferences = Preferences.load()
        self.url = URL(string: preferences!.rulesUpdateURL)
    }
    
    func getRules(callback : @escaping QueryResult) {
        task?.cancel()
        
        task = session.dataTask(with: url!) { [weak self] data, response, error in
            defer {
                self?.task = nil
            }
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                self?.logger.debug("rules downloaded..converting from json..")
                let rules = self?.processData(data)
                self?.logger.debug("rules have been converted")
                
                DispatchQueue.main.async {
                    callback(rules, self?.errorMessage ?? "")
                }
            }
        }
        
        logger.debug("starting to download rules..")
        task?.resume()
    }
    
    private func processData(_ data: Data) -> Optional<Rules> {
        let newRules : JSONRules = Helpers.loadJSON(data)
        return newRules.convert()
    }
}
