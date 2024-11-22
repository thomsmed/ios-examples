//
//  RootView.swift
//  VerticalSlices
//
//  Created by Thomas Asheim Smedmann on 21/10/2024.
//

import SwiftUI

struct RootView: View {
    @State private var signedOut: Bool = false

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }

            Tab("Explore", systemImage: "magnifyingglass") {
                ExploreView()
            }

            Tab("More", systemImage: "square.grid.2x2") {
                MoreView()
            }
        }
        .sheet(isPresented: $signedOut) {
            LoginView()
        }
    }
}

#Preview {
    RootView()
}
