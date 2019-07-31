//
//  ContentView.swift
//  test_swift
//
//  Created by Alex Lisle on 7/24/19.
//  Copyright © 2019 Alex Lisle. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    var body: some View {
        Text("Hello World")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
