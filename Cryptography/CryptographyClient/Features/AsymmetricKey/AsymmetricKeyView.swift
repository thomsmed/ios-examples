//
//  AsymmetricKeyView.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 18/03/2024.
//

import SwiftUI
import Combine
import CryptoKit
import JOSESwift

struct AsymmetricKeyView: View {
    @StateObject private var viewModel: Model = .init()

    var body: some View {
        Form {
            Section("Asymmetric Key Sharing and Signing") {
                HStack {
                    TextField(
                        "Write something to package and sign...",
                        text: $viewModel.input
                    )
                    .onSubmit(viewModel.didSubmitForSigning)

                    Button("Send", action: viewModel.didSubmitForSigning)
                }
            }

            Section("Asymmetric Key Sharing and Encryption") {
                HStack {
                    TextField(
                        "Write something to package and encrypt...",
                        text: $viewModel.input
                    )
                    .onSubmit(viewModel.didSubmitForEncryption)

                    Button("Send", action: viewModel.didSubmitForEncryption)
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

extension AsymmetricKeyView {
    final class Model: ObservableObject {
        @Published var input: String = ""

        @Published var sent: String = ""
        @Published var received: String = ""
    }
}

extension AsymmetricKeyView.Model {
    struct JWTPayload: Codable {
        let message: String
    }

    func didSubmitForSigning() {
        Task { @MainActor in
            do {
                let privateKey = P256.Signing.PrivateKey()

                let message = self.input.trimmingCharacters(in: .whitespacesAndNewlines)

                self.input = ""

                guard !message.isEmpty else {
                    return
                }

                let header = JWT.Signing.Header(jwk: privateKey.publicKey.jwkRepresentation)
                let jwtPayload = JWTPayload(message: message)
                let signer = ES256Signer(signingKey: privateKey)

                let jws = try JWS(header: header, payload: jwtPayload, signer: signer)

                let url = URL(string: "http://localhost:8080/asymmetric/signing")!

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/jwt", forHTTPHeaderField: "Content-Type")
                request.setValue("application/jwt", forHTTPHeaderField: "Accept")
                request.httpBody = try jws.compactSerializedData

                self.sent = message

                let (serverJWSData, serverJWSResponse) = try await URLSession.shared.data(for: request)

                let serverJWSHTTPURLResponse = serverJWSResponse as! HTTPURLResponse

                guard serverJWSHTTPURLResponse.statusCode == 200 else {
                    return assertionFailure("Unexpected HTTP status code: \(serverJWSHTTPURLResponse.statusCode)")
                }

                guard let serverJWS = JWS<JWTPayload>(compactSerializedData: serverJWSData) else {
                    return assertionFailure("Expected Server JWS decoding to succeed")
                }

                let serverJWKURL = URL(string: "http://localhost:8080/jwk/signing")!

                var serverJWKRequest = URLRequest(url: serverJWKURL)
                serverJWKRequest.httpMethod = "GET"
                serverJWKRequest.setValue("application/jwt", forHTTPHeaderField: "Accept")

                let (serverJWKData, serverJWKResponse) = try await URLSession.shared.data(for: serverJWKRequest)

                let serverJWKHTTPURLResponse = serverJWKResponse as! HTTPURLResponse

                guard serverJWKHTTPURLResponse.statusCode == 200 else {
                    return assertionFailure("Unexpected HTTP status code: \(serverJWKHTTPURLResponse.statusCode)")
                }

                guard let serverJWK = JWK(serialized: serverJWKData) else {
                    return assertionFailure("Expected Server JWK decoding to succeed")
                }

                guard let serverPublicKey = P256.Signing.PublicKey(jwkRepresentation: serverJWK) else {
                    return assertionFailure("Expected Server PublicKey decoding to succeed")
                }

                guard let validatedServerJWS = try serverJWS.validated(using: ES256Validator(validationKey: serverPublicKey)) else {
                    return assertionFailure("Expected Server JWS validation to succeed")
                }

                self.received = validatedServerJWS.payload.message
            } catch {
                print("Error:", error)
            }
        }
    }

    func didSubmitForEncryption() {
        Task { @MainActor in
            do {
                let privateKey = P256.Signing.PrivateKey()

                let message = self.input.trimmingCharacters(in: .whitespacesAndNewlines)

                self.input = ""

                guard !message.isEmpty else {
                    return
                }

                let jwtPayload = JWTPayload(message: message)

                // TODO: Make JWE

                let url = URL(string: "http://localhost:8080/asymmetric/encryption")!

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/jwt", forHTTPHeaderField: "Content-Type")

                self.sent = message

                let (data, response) = try await URLSession.shared.data(for: request)

                let httpURLResponse = response as! HTTPURLResponse

                guard httpURLResponse.statusCode == 200 else {
                    return assertionFailure("Unexpected HTTP status code: \(httpURLResponse.statusCode)")
                }

                // TODO: Get server JWK and decrypt received JWE

                self.received = String(data: data, encoding: .utf8)!
            } catch {
                print("Error:", error)
            }
        }
    }
}

#Preview {
    HashFunctionsView()
}
