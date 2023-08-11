//
//  JWK.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 23/03/2024.
//

import Foundation
import CryptoKit

/// [JSON Web Key (JWK)](https://datatracker.ietf.org/doc/html/rfc7517).
public struct JWK: Codable {
    // Common
    public let kty: String
    public var kid: String?

    // Elliptic Curve
    public let crv: String
    public let x: String
    public let y: String
    public let d: String? // For private keys only.

    internal init(kty: String, kid: String?, crv: String, x: String, y: String, d: String?) {
        self.kty = kty
        self.kid = kid
        self.crv = crv
        self.x = x
        self.y = y
        self.d = d
    }
}

// MARK: JWK+serialized

public extension JWK {
    init?(serialized: Data) {
        guard let jwk = try? JWT.decoder.decode(Self.self, from: serialized) else {
            return nil
        }

        self = jwk
    }

    init?(serialized: String) {
        guard
            let data = serialized.data(using: .utf8),
            let jwk = try? JWT.decoder.decode(Self.self, from: data)
        else {
            return nil
        }

        self = jwk
    }

    var serialized: Data {
        try! JWT.encoder.encode(self)
    }

    var serializedString: String {
        String(data: serialized, encoding: .utf8)!
    }
}

// MARK: JWK+ECxxx

public extension JWK {
    static func EC256(kid: String?, x: String, y: String, d: String? = nil) -> JWK {
        JWK(kty: "EC", kid: kid, crv: "P-256", x: x, y: y, d: d)
    }

    static func EC384(kid: String?, x: String, y: String, d: String? = nil) -> JWK {
        JWK(kty: "EC", kid: kid, crv: "P-384", x: x, y: y, d: d)
    }

    static func EC521(kid: String?, x: String, y: String, d: String? = nil) -> JWK {
        JWK(kty: "EC", kid: kid, crv: "P-521", x: x, y: y, d: d)
    }
}
