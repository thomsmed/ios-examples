//
//  SignalingDefaultsView.swift
//  SignalingStorage
//
//  Created by Thomas Smedmann on 23/03/2025.
//

import SwiftUI

struct SignalingDefaultsView: View {
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

    private let defaults: SignalingDefaults = .shared

    @SignalingDefaulted(key: "key", namespace: "namespace") private var defaultedString: String?

    @SynchronizedDefaulted(key: "key", namespace: "namespace") private var synchronizedString: String?

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

            NestedView(defaultedString: $synchronizedString)

            Button("Tap me!") {
                Task.detached {
                    let randomNumber = Int.random(in: 0..<100)
                    try? defaults.set("\(randomNumber)", for: "key", under: "namespace")
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
    SignalingDefaultsView()
}
