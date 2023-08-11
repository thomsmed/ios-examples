//
//  JWT.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 24/03/2024.
//

import Foundation

/// A common namespace for the [Javascript Object Signing and Encryption (JOSE)](https://datatracker.ietf.org/wg/jose/about/) standards.
public enum JWT {
    public static let dot = ".".data(using: .utf8)!

    public static var encoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    public static var decoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
}

public extension JWT {
    /// [JSON Web Signature (JWS)](https://datatracker.ietf.org/doc/html/rfc7515).
    enum Signing {
        /// [Cryptographic Algorithms for Digital Signatures and MACs](https://datatracker.ietf.org/doc/html/rfc7518#section-3).
        public enum SigningAlgorithm: String, Codable {
            case ES256
            case none
        }

        /// [JOSE Header](https://datatracker.ietf.org/doc/html/rfc7515#section-4).
        public struct Header: Codable {
            public let typ: String?
            public let cty: String?

            public var alg: SigningAlgorithm?

            public var jwk: JWK?

            // var additionalParameters: [String: Any] = [:]

            public init(jwk: JWK?) {
                self.typ = "JWS"
                self.cty = nil

                self.alg = nil
                self.jwk = jwk
            }
        }
    }
}

public extension JWT {
    /// [JSON Web Encryption (JWE)](https://datatracker.ietf.org/doc/html/rfc7516).
    enum Encryption {
        /// [Cryptographic Algorithms for Key Management](https://datatracker.ietf.org/doc/html/rfc7518#section-4).
        public enum KeyManagementAlgorithm: String, Codable {
            case dir = "dir"
            case ECDHES = "ECDH-ES"
        }

        /// [Cryptographic Algorithms for Content Encryption](https://datatracker.ietf.org/doc/html/rfc7518#section-5).
        public enum ContentEncryptionAlgorithm: String, Codable {
            case A128GCM
            case A192GCM
            case A256GCM

            /// The number of bits in the symmetric key.
            var bitCount: Int {
                switch self {
                    case .A128GCM: 128
                    case .A192GCM: 192
                    case .A256GCM: 256
                }
            }
        }

        /// [JOSE Header](https://datatracker.ietf.org/doc/html/rfc7516#section-4).
        public struct Header: Codable {
            public let typ: String?
            public let cty: String?

            public var alg: KeyManagementAlgorithm?
            public var enc: ContentEncryptionAlgorithm?

            public var jwk: JWK?

            // var additionalParameters: [String: Any] = [:]

            public init(jwk: JWK?) {
                self.typ = "JWE"
                self.cty = nil

                self.alg = nil
                self.enc = nil

                self.jwk = jwk
            }
        }
    }
}
