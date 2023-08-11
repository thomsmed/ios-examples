//
//  SymmetricKeyView.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 17/03/2024.
//

import SwiftUI
import Combine
import CryptoKit
import JOSESwift

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

            Section("Shared Symmetric Key w/Authenticity") {
                HStack {
                    TextField(
                        "Write something to encrypt...",
                        text: $viewModel.input
                    )
                    .onSubmit(viewModel.didSubmitWithAuthenticity)

                    Button("Send", action: viewModel.didSubmitWithAuthenticity)
                }
            }

            Section("Derived Symmetric Key") {
                HStack {
                    TextField(
                        "Write something to encrypt...",
                        text: $viewModel.input
                    )
                    .onSubmit(viewModel.didSubmitForKeyAgreement)

                    Button("Send", action: viewModel.didSubmitForKeyAgreement)
                }
            }

            Section("Derived Symmetric Key w/Authenticity") {
                HStack {
                    TextField(
                        "Write something to encrypt...",
                        text: $viewModel.input
                    )
                    .onSubmit(viewModel.didSubmitForKeyAgreementWithAuthenticity)

                    Button("Send", action: viewModel.didSubmitForKeyAgreementWithAuthenticity)
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
    final class Model: ObservableObject {
        @Published var input: String = ""

        @Published var sent: String = ""
        @Published var received: String = ""
    }
}

extension SymmetricKeyView.Model {
    struct SharedSymmetricKeyRequest: Encodable {
        let message: Data
    }

    struct SharedSymmetricKeyResponse: Decodable {
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

                let requestPayload = SharedSymmetricKeyRequest(message: cipherText)

                let url = URL(string: "http://localhost:8080/symmetric/shared")!

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.httpBody = try JSONEncoder().encode(requestPayload)

                self.sent = plainText

                let (data, response) = try await URLSession.shared.data(for: request)

                let httpURLResponse = response as! HTTPURLResponse

                guard httpURLResponse.statusCode == 200 else {
                    return assertionFailure("Unexpected HTTP status code: \(httpURLResponse.statusCode)")
                }

                let responsePayload = try JSONDecoder().decode(SharedSymmetricKeyResponse.self, from: data)
                let receivedCipherText = responsePayload.message

                let receivedSealedBox = try AES.GCM.SealedBox(combined: receivedCipherText)
                let receivedPlainText = try AES.GCM.open(receivedSealedBox, using: symmetricKey)

                self.received = String(data: receivedPlainText, encoding: .utf8)!
            } catch {
                print("Error:", error)
            }
        }
    }

    struct SharedSymmetricKeyAuthenticityRequest: Encodable {
        let header: Data
        let nonce: Data
        let cipherText: Data
        let tag: Data
    }

    struct SharedSymmetricKeyAuthenticityResponse: Decodable {
        let header: Data
        let nonce: Data
        let cipherText: Data
        let tag: Data
    }

    func didSubmitWithAuthenticity() {
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

                let header = "<client-authenticity-header>".data(using: .utf8)!
                let sealedBox = try AES.GCM.seal(
                    plainText.data(using: .utf8)!,
                    using: symmetricKey,
                    authenticating: header
                )

                let requestPayload = SharedSymmetricKeyAuthenticityRequest(
                    header: header,
                    nonce: Data(sealedBox.nonce),
                    cipherText: sealedBox.ciphertext,
                    tag: sealedBox.tag
                )

                let url = URL(string: "http://localhost:8080/symmetric/shared/authenticity")!

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.httpBody = try JSONEncoder().encode(requestPayload)

                self.sent = plainText

                let (data, response) = try await URLSession.shared.data(for: request)

                let httpURLResponse = response as! HTTPURLResponse

                guard httpURLResponse.statusCode == 200 else {
                    return assertionFailure("Unexpected HTTP status code: \(httpURLResponse.statusCode)")
                }

                let responsePayload = try JSONDecoder().decode(SharedSymmetricKeyAuthenticityResponse.self, from: data)

                let receivedSealedBox = try AES.GCM.SealedBox(
                    nonce: AES.GCM.Nonce(data: responsePayload.nonce),
                    ciphertext: responsePayload.cipherText,
                    tag: responsePayload.tag
                )
                let receivedPlainText = try AES.GCM.open(
                    receivedSealedBox,
                    using: symmetricKey,
                    authenticating: responsePayload.header
                )

                self.received = String(data: receivedPlainText, encoding: .utf8)!
            } catch {
                print("Error:", error)
            }
        }
    }

    struct DerivedSymmetricKeyRequest: Encodable {
        let serializedPublicKey: String
        let message: Data
    }

    struct DerivedSymmetricKeyResponse: Decodable {
        let message: Data
    }

    func didSubmitForKeyAgreement() {
        Task { @MainActor in
            do {
                let plainText = self.input.trimmingCharacters(in: .whitespacesAndNewlines)

                self.input = ""

                guard !plainText.isEmpty else {
                    return
                }

                let serverJWKURL = URL(string: "http://localhost:8080/jwk/encryption")!

                var serverJWKRequest = URLRequest(url: serverJWKURL)
                serverJWKRequest.httpMethod = "GET"
                serverJWKRequest.setValue("application/jwt", forHTTPHeaderField: "Accept")

                let (serverJWKData, serverJWKResponse) = try await URLSession.shared.data(for: serverJWKRequest)

                let serverHTTPURLResponse = serverJWKResponse as! HTTPURLResponse

                guard serverHTTPURLResponse.statusCode == 200 else {
                    return assertionFailure("Unexpected HTTP status code: \(serverHTTPURLResponse.statusCode)")
                }

                guard let serverJWK = JWK(serialized: serverJWKData) else {
                    return assertionFailure("Expected Server JWK decoding to succeed")
                }

                guard let serverPublicKey = P256.KeyAgreement.PublicKey(jwkRepresentation: serverJWK) else {
                    return assertionFailure("Expected Server PublicKey decoding to succeed")
                }

                let privateKey = P256.KeyAgreement.PrivateKey()

                let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: serverPublicKey)

                let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
                    using: SHA256.self,
                    salt: Data(),
                    sharedInfo: Data(),
                    outputByteCount: 256 / 8
                )

                assert(symmetricKey.bitCount == 256)

                let sealedBox = try AES.GCM.seal(plainText.data(using: .utf8)!, using: symmetricKey)
                let cipherText = sealedBox.combined!

                let requestPayload = DerivedSymmetricKeyRequest(
                    serializedPublicKey: privateKey.publicKey.jwkRepresentation.serializedString,
                    message: cipherText
                )

                let url = URL(string: "http://localhost:8080/symmetric/derived")!

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.httpBody = try JSONEncoder().encode(requestPayload)

                self.sent = plainText

                let (data, response) = try await URLSession.shared.data(for: request)

                let httpURLResponse = response as! HTTPURLResponse

                guard httpURLResponse.statusCode == 200 else {
                    return assertionFailure("Unexpected HTTP status code: \(httpURLResponse.statusCode)")
                }

                let decodedResponse = try JSONDecoder().decode(DerivedSymmetricKeyResponse.self, from: data)
                let receivedCipherText = decodedResponse.message

                let receivedSealedBox = try AES.GCM.SealedBox(combined: receivedCipherText)
                let receivedPlainText = try AES.GCM.open(receivedSealedBox, using: symmetricKey)

                self.received = String(data: receivedPlainText, encoding: .utf8)!
            } catch {
                print("Error:", error)
            }
        }
    }

    struct DerivedSymmetricKeyAuthenticityRequest: Encodable {
        let serializedPublicKey: String
        let header: Data
        let nonce: Data
        let cipherText: Data
        let tag: Data
    }

    struct DerivedSymmetricKeyAuthenticityResponse: Decodable {
        let header: Data
        let nonce: Data
        let cipherText: Data
        let tag: Data
    }

    func didSubmitForKeyAgreementWithAuthenticity() {
        Task { @MainActor in
            do {
                let plainText = self.input.trimmingCharacters(in: .whitespacesAndNewlines)

                self.input = ""

                guard !plainText.isEmpty else {
                    return
                }

                let serverJWKURL = URL(string: "http://localhost:8080/jwk/encryption")!

                var serverJWKRequest = URLRequest(url: serverJWKURL)
                serverJWKRequest.httpMethod = "GET"
                serverJWKRequest.setValue("application/jwt", forHTTPHeaderField: "Accept")

                let (serverJWKData, serverJWKResponse) = try await URLSession.shared.data(for: serverJWKRequest)

                let serverHTTPURLResponse = serverJWKResponse as! HTTPURLResponse

                guard serverHTTPURLResponse.statusCode == 200 else {
                    return assertionFailure("Unexpected HTTP status code: \(serverHTTPURLResponse.statusCode)")
                }

                guard let serverJWK = JWK(serialized: serverJWKData) else {
                    return assertionFailure("Expected Server JWK decoding to succeed")
                }

                guard let serverPublicKey = P256.KeyAgreement.PublicKey(jwkRepresentation: serverJWK) else {
                    return assertionFailure("Expected Server PublicKey decoding to succeed")
                }

                let privateKey = P256.KeyAgreement.PrivateKey()

                let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: serverPublicKey)

                let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
                    using: SHA256.self,
                    salt: Data(),
                    sharedInfo: Data(),
                    outputByteCount: 256 / 8
                )

                assert(symmetricKey.bitCount == 256)

                let header = "<client-authenticity-header>".data(using: .utf8)!
                let sealedBox = try AES.GCM.seal(
                    plainText.data(using: .utf8)!,
                    using: symmetricKey,
                    authenticating: header
                )

                let requestPayload = DerivedSymmetricKeyAuthenticityRequest(
                    serializedPublicKey: privateKey.publicKey.jwkRepresentation.serializedString,
                    header: header,
                    nonce: Data(sealedBox.nonce),
                    cipherText: sealedBox.ciphertext,
                    tag: sealedBox.tag
                )

                let url = URL(string: "http://localhost:8080/symmetric/derived/authenticity")!

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.httpBody = try JSONEncoder().encode(requestPayload)

                self.sent = plainText

                let (data, response) = try await URLSession.shared.data(for: request)

                let httpURLResponse = response as! HTTPURLResponse

                guard httpURLResponse.statusCode == 200 else {
                    return assertionFailure("Unexpected HTTP status code: \(httpURLResponse.statusCode)")
                }

                let responsePayload = try JSONDecoder().decode(DerivedSymmetricKeyAuthenticityResponse.self, from: data)

                let receivedSealedBox = try AES.GCM.SealedBox(
                    nonce: AES.GCM.Nonce(data: responsePayload.nonce),
                    ciphertext: responsePayload.cipherText,
                    tag: responsePayload.tag
                )
                let receivedPlainText = try AES.GCM.open(
                    receivedSealedBox,
                    using: symmetricKey,
                    authenticating: responsePayload.header
                )

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
