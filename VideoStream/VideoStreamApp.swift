//
//  VideoStreamApp.swift
//  VideoStream
//
//  Created by Nandini Thakur on 3/20/24.
//

import SwiftUI

@main
struct VideoStreamApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
