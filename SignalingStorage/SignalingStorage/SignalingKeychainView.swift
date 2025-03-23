//
//  SignalingKeychainView.swift
//  SignalingStorage
//
//  Created by Thomas Smedmann on 23/03/2025.
//

import SwiftUI

struct SignalingKeychainView: View {
    struct NestedView: View {
        @Binding var keyChainedData: String?

        var body: some View {
            Button("Tap me!") {
                Task.detached {
                    await MainActor.run {
                        let randomNumber = Int.random(in: 0..<100)
                        keyChainedData = "\(randomNumber)"
                    }
                }
            }
        }
    }

    private let keyChain: SignalingKeychain = .shared

    @SignalingKeychained(key: "key", namespace: "namespace") private var keyChainedData: String?

    var body: some View {
        VStack {
            if let string: String = try? keyChain.value(for: "key", under: "namespace") {
                Text("From KeyChain: \(string)")
            } else {
                Text("From KeyChain: <nothing>")
            }

            if let keyChainedData {
                Text("From KeyChain: \(keyChainedData)")
            } else {
                Text("From KeyChain: <nothing>")
            }

            NestedView(keyChainedData: $keyChainedData)

            Button("Tap me!") {
                Task.detached {
                    let randomNumber = Int.random(in: 0..<100)
                    try? keyChain.set("\(randomNumber)", for: "key", under: "namespace")
                }
            }

            Button("Tap me!") {
                Task.detached {
                    await MainActor.run {
                        let randomNumber = Int.random(in: 0..<100)
                        keyChainedData = "\(randomNumber)"
                    }
                }
            }
        }
    }
}

#Preview {
    SignalingKeychainView()
}
