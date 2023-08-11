//
//  JWSValidator.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 28/03/2024.
//

import Foundation
import CryptoKit

public protocol JWSValidator {
    func validate<Payload: Codable>(_ jws: JWS<Payload>) throws -> Bool
}

// MARK: NoneValidator

/// [Unsecure JWTs](https://datatracker.ietf.org/doc/html/rfc7519#section-6).
public struct NoneValidator: JWSValidator {
    public func validate<Payload: Codable>(_ jws: JWS<Payload>) throws -> Bool {
        guard jws.header.alg == JWT.Signing.SigningAlgorithm.none else {
            return false
        }

        return true
    }
}

// MARK: ES256Validator

public struct ES256Validator: JWSValidator {
    public let validationKey: P256.Signing.PublicKey

    public init(validationKey: P256.Signing.PublicKey) {
        self.validationKey = validationKey
    }

    public func validate<Payload: Codable>(_ jws: JWS<Payload>) throws -> Bool {
        guard jws.header.alg == .ES256 else {
            return false
        }

        let serializedHeader = try JWT.encoder.encode(jws.header)
        let serializedPayload = try JWT.encoder.encode(jws.payload)

        let dataToBeValidated = serializedHeader.base64URLEncoded()! + JWT.dot + serializedPayload.base64URLEncoded()!

        let digest = SHA256.hash(data: dataToBeValidated)
        let ecdsaSignature = try P256.Signing.ECDSASignature(rawRepresentation: jws.signature)

        return validationKey.isValidSignature(ecdsaSignature, for: digest)
    }
}
