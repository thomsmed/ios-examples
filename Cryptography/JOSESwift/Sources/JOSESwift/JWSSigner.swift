//
//  JWSSigner.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 28/03/2024.
//

import Foundation
import CryptoKit

public protocol JWSSigner {
    func sign<Payload: Codable>(_ header: JWT.Signing.Header, payload: Payload) throws -> JWS<Payload>
}

// MARK: NoneSigner

/// [Unsecure JWTs](https://datatracker.ietf.org/doc/html/rfc7519#section-6).
public struct NoneSigner: JWSSigner {
    public func sign<Payload: Codable>(_ header: JWT.Signing.Header, payload: Payload) throws -> JWS<Payload> {
        var header = header
        header.alg = JWT.Signing.SigningAlgorithm.none

        return JWS(
            header: header,
            payload: payload,
            signature: Data()
        )
    }
}

// MARK: ES256Signer

public struct ES256Signer: JWSSigner {
    public let signingKey: P256.Signing.PrivateKey

    public init(signingKey: P256.Signing.PrivateKey) {
        self.signingKey = signingKey
    }

    public func sign<Payload: Codable>(_ header: JWT.Signing.Header, payload: Payload) throws -> JWS<Payload> {
        var header = header
        header.alg = .ES256

        let serializedHeader = try JWT.encoder.encode(header)
        let serializedPayload = try JWT.encoder.encode(payload)

        let dataToBeSigned = serializedHeader.base64URLEncoded()! + JWT.dot + serializedPayload.base64URLEncoded()!

        let digest = SHA256.hash(data: dataToBeSigned)
        let signature = try signingKey.signature(for: digest)

        return JWS(
            header: header,
            payload: payload,
            signature: signature.rawRepresentation
        )
    }
}
