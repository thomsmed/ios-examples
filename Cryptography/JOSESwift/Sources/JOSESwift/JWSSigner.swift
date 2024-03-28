//
//  JWSSigner.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 28/03/2024.
//

import Foundation
import CryptoKit

public protocol JWSSigner {
    var algorithm: JWT.Signing.Algorithm { get }
    func sign(_ data: Data) throws -> Data
}

// MARK: NoneSigner

/// [Unsecure JWTs](https://datatracker.ietf.org/doc/html/rfc7519#section-6).
public struct NoneSigner: JWSSigner {
    public let algorithm: JWT.Signing.Algorithm = .none

    public func sign(_ data: Data) throws -> Data {
        Data()
    }
}

// MARK: ES256Signer

public struct ES256Signer: JWSSigner {
    public let algorithm: JWT.Signing.Algorithm = .ES256

    public let signingKey: P256.Signing.PrivateKey

    public init(signingKey: P256.Signing.PrivateKey) {
        self.signingKey = signingKey
    }

    public func sign(_ data: Data) throws -> Data {
        let digest = SHA256.hash(data: data)
        let signature = try signingKey.signature(for: digest)
        return signature.rawRepresentation
    }
}
