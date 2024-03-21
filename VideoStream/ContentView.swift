//
//  ContentView.swift
//  VideoStream
//
//  Created by Nandini Thakur on 3/20/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    var body: some View {
        Button {
            Task {
                await self.openImmersiveSpace(id: "ImmersiveSpace")
                self.dismissWindow()
            }
        } label: {
            Text("Start")
                .font(.largeTitle)
                .padding(.vertical, 12)
                .padding(.horizontal, 4)
        }
    }
}

//#Preview(windowStyle: .automatic) {
//    ContentView()
//}
