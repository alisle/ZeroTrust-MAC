//
//  TimeIntervalExtension.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 9/4/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

extension TimeInterval {
    func formattedString() -> String {
        let time = Int(self)
         let seconds = time % 60
         let minutes = (time / 60) % 60
         let hours = (time / 3600)

         return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
}
