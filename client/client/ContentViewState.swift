//
//  ContentViewState.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 8/21/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import Foundation

final class ContentViewState: ObservableObject {
    @Published var filterBy : ViewLength = .current
}
