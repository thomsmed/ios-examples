//
//  ContentView.swift
//  GesturesAndSpriteKit
//
//  Created by Thomas Smedmann on 31/08/2025.
//

import SwiftUI
import SpriteKit

struct ContentView: View {

    @State private var scene = GameScene()

    @State private var gamePaused: Bool = false
    @State private var nodesHidden: Bool = false

    var body: some View {
        NavigationStack {
            SpriteView(
                scene: scene,
                isPaused: gamePaused,
                preferredFramesPerSecond: 120,
                debugOptions: [
                    .showsFPS,
                    .showsDrawCount,
                    .showsFields,
                    .showsNodeCount,
                    .showsPhysics,
                    .showsQuadCount,
                ]
            )
            .ignoresSafeArea()
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Reset World", systemImage: "location.magnifyingglass") {
                        scene.resetWorld()
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(nodesHidden ? "Show" : "Hide") {
                        nodesHidden.toggle()
                    }

                    Button(gamePaused ? "Resume" : "Pause") {
                        gamePaused.toggle()
                    }
                }
            }
            .onChange(of: nodesHidden) {
                scene.isHidden = nodesHidden
            }
            .onChange(of: gamePaused) {
                scene.isPaused = gamePaused
            }
        }
    }
}

#Preview {
    ContentView()
}
