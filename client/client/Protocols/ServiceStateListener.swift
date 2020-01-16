//
//  ServiceStateListener.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 1/16/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import Foundation

protocol ServiceStateListener {
    func serviceStateChanged(type: ServiceStateType, serviceEnabled: Bool)
}
