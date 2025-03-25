//
//  ObservableKeychainView.swift
//  SignalingStorage
//
//  Created by Thomas Smedmann on 23/03/2025.
//

import SwiftUI

struct ObservableKeychainView: View {
    struct NestedView: View {
        @Binding var keychainedString: String?

        var body: some View {
            Button("Tap me!") {
                Task.detached {
                    await MainActor.run {
                        let randomNumber = Int.random(in: 0..<100)
                        keychainedString = "\(randomNumber)"
                    }
                }
            }
        }
    }

    @ObservedObject private var keychain: ObservableKeychain = .shared

    @ObservedKeychained(key: "key", namespace: "namespace") private var keychainedString: String?

    var body: some View {
        VStack {
            if let string: String = try? keychain.value(for: "key", under: "namespace") {
                Text("From KeyChain: \(string)")
            } else {
                Text("From KeyChain: <nothing>")
            }

            if let keychainedString {
                Text("From KeyChain: \(keychainedString)")
            } else {
                Text("From KeyChain: <nothing>")
            }

            NestedView(keychainedString: $keychainedString)

            Button("Tap me!") {
                Task.detached {
                    let randomNumber = Int.random(in: 0..<100)
                    try? await keychain.set("\(randomNumber)", for: "key", under: "namespace")
                }
            }

            Button("Tap me!") {
                Task.detached {
                    await MainActor.run {
                        let randomNumber = Int.random(in: 0..<100)
                        keychainedString = "\(randomNumber)"
                    }
                }
            }
        }
    }
}

#Preview {
    ObservableKeychainView()
}
