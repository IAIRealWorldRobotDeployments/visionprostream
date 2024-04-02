//
//  VideoStreamApp.swift
//  VideoStream
//
//  Created by Nandini Thakur on 3/20/24.
//

import SwiftUI

@main
struct VideoStreamApp: App {
    @StateObject private var imageData = ImageData()
    @State var immersionMode: ImmersionStyle = .full
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView().environmentObject(imageData)
        }
        .immersionStyle(selection: $immersionMode, in: .full)
    }
}
