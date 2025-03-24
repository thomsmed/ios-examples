//
//  ObservableDefaultsView.swift
//  SignalingStorage
//
//  Created by Thomas Smedmann on 23/03/2025.
//

import SwiftUI

struct ObservableDefaultsView: View {
    struct NestedView: View {
        @Binding var defaultedString: String?

        var body: some View {
            Button("Tap me!") {
                Task.detached {
                    await MainActor.run {
                        let randomNumber = Int.random(in: 0..<100)
                        defaultedString = "\(randomNumber)"
                    }
                }
            }
        }
    }

    @ObservedObject private var defaults: ObservableDefaults = .shared

    @ObservedDefaulted(key: "key", namespace: "namespace") private var defaultedString: String?

    var body: some View {
        VStack {
            if let string: String = try? defaults.value(for: "key", under: "namespace") {
                Text("From UserDefaults: \(string)")
            } else {
                Text("From UserDefaults: <nothing>")
            }

            if let defaultedString {
                Text("From UserDefaults: \(defaultedString)")
            } else {
                Text("From UserDefaults: <nothing>")
            }

            NestedView(defaultedString: $defaultedString)

            Button("Tap me!") {
                Task.detached {
                    let randomNumber = Int.random(in: 0..<100)
                    try? await defaults.set("\(randomNumber)", for: "key", under: "namespace")
                }
            }

            Button("Tap me!") {
                Task.detached {
                    await MainActor.run {
                        let randomNumber = Int.random(in: 0..<100)
                        defaultedString = "\(randomNumber)"
                    }
                }
            }
        }
    }
}

#Preview {
    ObservableDefaultsView()
}
