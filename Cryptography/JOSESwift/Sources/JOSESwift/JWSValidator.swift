//
//  JWSValidator.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 28/03/2024.
//

import Foundation
import CryptoKit

public protocol JWSValidator {
    var algorithm: JWT.Signing.Algorithm { get }
    func validate(_ data: Data, against signature: Data) throws -> Bool
}

// MARK: NoneValidator

/// [Unsecure JWTs](https://datatracker.ietf.org/doc/html/rfc7519#section-6).
public struct NoneValidator: JWSValidator {
    public let algorithm: JWT.Signing.Algorithm = .none

    public func validate(_ data: Data, against signature: Data) throws -> Bool {
        true
    }
}

// MARK: ES256Validator

public struct ES256Validator: JWSValidator {
    public let algorithm: JWT.Signing.Algorithm = .ES256

    public let validationKey: P256.Signing.PublicKey

    public init(validationKey: P256.Signing.PublicKey) {
        self.validationKey = validationKey
    }

    public func validate(_ data: Data, against signature: Data) throws -> Bool {
        let digest = SHA256.hash(data: data)
        let ecdsaSignature = try P256.Signing.ECDSASignature(rawRepresentation: signature)
        return validationKey.isValidSignature(ecdsaSignature, for: digest)
    }
}
