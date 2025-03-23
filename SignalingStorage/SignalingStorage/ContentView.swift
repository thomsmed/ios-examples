//
//  ContentView.swift
//  SignalingStorage
//
//  Created by Thomas Smedmann on 23/03/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab {
                VStack {
                    ObservableDefaultsView()
                    ObservableKeychainView()
                }
            } label: {
                Text("Observable")
            }

            Tab {
                VStack {
                    SignalingDefaultsView()
                    SignalingKeychainView()
                }
            } label: {
                Text("Signaling")
            }
        }
    }
}

#Preview {
    ContentView()
}
