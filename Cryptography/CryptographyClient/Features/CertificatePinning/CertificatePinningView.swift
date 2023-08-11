//
//  CertificatePinningView.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 20/08/2023.
//

import SwiftUI
import CryptoKit

struct CertificatePinningView: View {
    @StateObject private var viewModel: Model = .init()

    var body: some View {
        Form {
            Section {
                Button("Click me!", action: viewModel.doNetworkRequest)
            }
        }
    }
}

extension CertificatePinningView {
    private class PinningURLSessionDelegate: NSObject, URLSessionDelegate {

        // Common ASN1 headers for the Subject Public Key Info section of a certificate.
        // Ref: [TrustKit](https://github.com/datatheorem/TrustKit/blob/master/TrustKit/Pinning/TSKSPKIHashCache.m)
        static let rsa2048Asn1Header: [UInt8] =
        [
            0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
            0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
        ]

        static let rsa4096Asn1Header: [UInt8] =
        [
            0x30, 0x82, 0x02, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
            0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x02, 0x0f, 0x00
        ]

        static let ecDsaSecp256r1Asn1Header: [UInt8] =
        [
            0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
            0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03,
            0x42, 0x00
        ]

        static let ecDsaSecp384r1Asn1Header: [UInt8] =
        [
            0x30, 0x76, 0x30, 0x10, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
            0x01, 0x06, 0x05, 0x2b, 0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00
        ]

        private let supportedKeySizes: [String: [Int: [UInt8]]] = [
            kSecAttrKeyTypeRSA as String: [2048: rsa2048Asn1Header, 4096: rsa4096Asn1Header],
            kSecAttrKeyTypeECSECPrimeRandom as String: [256: ecDsaSecp256r1Asn1Header, 384: ecDsaSecp384r1Asn1Header]
        ]

        private func getSecCertificates(from serverTrust: SecTrust) -> [SecCertificate] {
            if #available(iOS 15, *) {
                // Certificates in the trust chain.
                let certificates = SecTrustCopyCertificateChain(serverTrust)

                return certificates as? [SecCertificate] ?? []
            } else {
                // Number of certificates in the trust chain.
                let certificateCount = SecTrustGetCertificateCount(serverTrust)

                var certificates: [SecCertificate] = []
                for index in 0..<certificateCount {
                    guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, index) else {
                        continue
                    }

                    certificates.append(certificate)
                }

                return certificates
            }
        }

        private func checkValidity(of serverTrust: SecTrust, with hostname: String, against hashes: [String]) -> Bool {
            // Evaluate Certificate Trust Chain (default SSL props?)
            var error: CFError?

            guard SecTrustEvaluateWithError(serverTrust, &error) else {
                return false
            }

            let certificates = getSecCertificates(from: serverTrust)

            // Get the leaf certificate's public key
            let publicKey: SecKey?
            if certificates.isEmpty {
                // Directly
                publicKey = SecTrustCopyKey(serverTrust)
            } else {
                // Or via certificate chain.
                publicKey  = SecCertificateCopyKey(certificates[0])
            }

            guard let publicKey else {
                return false
            }

            // Hash and compare the public key.
            guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as? Data else {
                return false
            }

            guard let attributes = SecKeyCopyAttributes(publicKey) as? [String: Any] else {
                return false
            }

            print("Public key attributes:", attributes)

            guard
                let algorithm = attributes[kSecAttrKeyType as String] as? String,
                let keySize = attributes[kSecAttrKeySizeInBits as String] as? Int
            else {
                return false
            }

            guard let asn1Header = supportedKeySizes[algorithm]?[keySize] else {
                return false
            }

            var publicKeyWithHeader = Data(asn1Header)
            publicKeyWithHeader.append(publicKeyData)

            let hash = Data(SHA256.hash(data: publicKeyWithHeader)).base64EncodedString()

            return hashes.contains(hash)
        }

        /// [Performing Manual Server Trust Authentication](https://developer.apple.com/documentation/foundation/url_loading_system/handling_an_authentication_challenge/performing_manual_server_trust_authentication)
        func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            let authenticationMethod = challenge.protectionSpace.authenticationMethod

            guard authenticationMethod == NSURLAuthenticationMethodServerTrust else {
                return completionHandler(.performDefaultHandling, nil)
            }

            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                assertionFailure("When is this ever nil?")
                return completionHandler(.performDefaultHandling, nil)
            }

            let pins: [String] = [
                "o86ufcpN54ma9MLu63xXMALtCF5h+clKIZHPGvqOHw4=" // Pin of the leaf TLS certificate's public key for `developer.apple.com`.
            ]

            if checkValidity(of: serverTrust, with: challenge.protectionSpace.host, against: pins) {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            } else {
                // Show a UI here warning the user the server credentials are
                // invalid, and cancel the load.
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
    }

    final class Model: ObservableObject {
        private let urlSession: URLSession

        init() {
            let configuration = URLSessionConfiguration.default

            urlSession = URLSession(
                configuration: configuration,
                delegate: PinningURLSessionDelegate(),
                delegateQueue: nil
            )
        }

        func doNetworkRequest() {
            Task {
                do {
                    let url = URL(string: "https://developer.apple.com")!

                    let (data, response) = try await urlSession.data(from: url)

                    guard
                        let httpResponse = response as? HTTPURLResponse,
                        httpResponse.statusCode == 200
                    else {
                        return assertionFailure("Why did this happen?")
                    }

                    guard let textResponse = String(data: data, encoding: .utf8) else {
                        return assertionFailure("Why did this happen?")
                    }

                    print("Text response:", textResponse)
                } catch {
                    assertionFailure("Why did this happen?")
                }
            }
        }
    }
}

#Preview {
    CertificatePinningView()
}
