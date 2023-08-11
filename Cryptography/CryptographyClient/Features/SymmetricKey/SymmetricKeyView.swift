//
//  SymmetricKeyView.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 17/03/2024.
//

import SwiftUI
import Combine
import CryptoKit

struct SymmetricKeyView: View {
    @StateObject private var viewModel: Model = .init()

    var body: some View {
        Form {
            Section("Shared Symmetric Key") {
                HStack {
                    TextField(
                        "Write something to encrypt...",
                        text: $viewModel.input
                    )
                    .onSubmit(viewModel.didSubmit)

                    Button("Send", action: viewModel.didSubmit)
                }
            }

            Section("Sent") {
                Text(viewModel.sent)
            }

            Section("Received") {
                Text(viewModel.received)
            }
        }
    }
}

extension SymmetricKeyView {

}

extension SymmetricKeyView {
    final class Model: ObservableObject {
        @Published var input: String = ""

        @Published var sent: String = ""
        @Published var received: String = ""
    }
}

extension SymmetricKeyView.Model {
    struct SharedSymmetricRequest: Encodable {
        let message: Data
    }

    struct SharedSymmetricResponse: Decodable {
        let message: Data
    }

    func didSubmit() {
        Task { @MainActor in
            do {
                // A shared symmetric key can be generated like so:
                // SymmetricKey(size: .bits256).withUnsafeBytes { buffer in
                //     let rawBase64KeyData = Data(buffer).base64EncodedString()
                //     print(rawBase64KeyData)
                // }

                let sharedSymmetricKeyData = Data(base64Encoded: "cE4AVV6G/9ft+jW8ofIosuiGhGA50/ZhHDtjTDfEdII=")!

                let symmetricKey = SymmetricKey(data: sharedSymmetricKeyData)

                let plainText = self.input.trimmingCharacters(in: .whitespacesAndNewlines)

                self.input = ""

                guard !plainText.isEmpty else {
                    return
                }

                let sealedBox = try AES.GCM.seal(plainText.data(using: .utf8)!, using: symmetricKey)
                let cipherText = sealedBox.combined!

                let url = URL(string: "http://localhost:8080/symmetric/shared")!

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONEncoder().encode(SharedSymmetricRequest(message: cipherText))

                self.sent = plainText

                let (data, response) = try await URLSession.shared.data(for: request)

                let httpURLResponse = response as! HTTPURLResponse

                guard httpURLResponse.statusCode == 200 else {
                    return assertionFailure("Unexpected HTTP status code: \(httpURLResponse.statusCode)")
                }

                let decodedResponse = try JSONDecoder().decode(SharedSymmetricResponse.self, from: data)
                let receivedCipherText = decodedResponse.message

                let receivedSealedBox = try AES.GCM.SealedBox(combined: receivedCipherText)
                let receivedPlainText = try AES.GCM.open(receivedSealedBox, using: symmetricKey)

                self.received = String(data: receivedPlainText, encoding: .utf8)!
            } catch {
                print("Error:", error)
            }
        }
    }
}

#Preview {
    HashFunctionsView()
}
