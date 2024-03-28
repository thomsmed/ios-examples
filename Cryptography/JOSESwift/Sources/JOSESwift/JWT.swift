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
        public enum Algorithm: String, Codable {
            case ES256
            case none
        }

        /// [JOSE Header](https://datatracker.ietf.org/doc/html/rfc7515#section-4).
        public struct Header: Codable {
            public let typ: String?
            public let cty: String?

            public var alg: Algorithm?
            public var jwk: JWK?

            // var additionalParameters: [String: Any] = [:]

            public init(algorithm: JWT.Signing.Algorithm?, jwk: JWK?) {
                self.typ = "JWS"
                self.cty = nil

                self.alg = algorithm
                self.jwk = jwk
            }
        }
    }
}

public extension JWT {
    /// [JSON Web Encryption (JWE)](https://datatracker.ietf.org/doc/html/rfc7516).
    enum Encryption {
        /// [Cryptographic Algorithms for Content Encryption](https://datatracker.ietf.org/doc/html/rfc7518#section-5).
        public enum Algorithm: String, Codable {
            case A256GCM
        }
    }
}
