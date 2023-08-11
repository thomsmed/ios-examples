//
//  JWS.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 23/03/2024.
//

import Foundation
import CryptoKit

/// [JSON Web Signature (JWS)](https://datatracker.ietf.org/doc/html/rfc7515).
public struct JWS<Payload: Codable> {
    public let header: JWT.Signing.Header
    public let payload: Payload
    public let signature: Data

    internal init(
        header: JWT.Signing.Header,
        payload: Payload,
        signature: Data
    ) {
        self.header = header
        self.payload = payload
        self.signature = signature
    }
}

public extension JWS {
    init(header: JWT.Signing.Header, payload: Payload, signer: some JWSSigner) throws {
        self = try signer.sign(header, payload: payload)
    }

    init(header: JWT.Signing.Header, payload: Payload) throws {
        try self.init(header: header, payload: payload, signer: NoneSigner())
    }

    init(payload: Payload) throws {
        let header = JWT.Signing.Header(jwk: nil)
        try self.init(header: header, payload: payload, signer: NoneSigner())
    }
}

// MARK: JWS+compactSerialized

public extension JWS {
    init?(compactSerializedString: String) {
        let compactSerializedComponents = compactSerializedString.compactSerializedComponents

        guard compactSerializedComponents.count == 3 else {
            return nil
        }

        guard let headerData = Data(base64URLEncoded: compactSerializedComponents[0]) else {
            return nil
        }

        guard let header = try? JWT.decoder.decode(JWT.Signing.Header.self, from: headerData) else {
            return nil
        }

        guard let payloadData = Data(base64URLEncoded: compactSerializedComponents[1]) else {
            return nil
        }

        guard let payload = try? JWT.decoder.decode(Payload.self, from: payloadData) else {
            return nil
        }

        guard let signature = Data(base64URLEncoded: compactSerializedComponents[2]) else {
            return nil
        }

        self.header = header
        self.payload = payload
        self.signature = signature
    }

    init?(compactSerializedData: Data) {
        guard let compactSerializedString = String(data: compactSerializedData, encoding: .utf8) else {
            return nil
        }

        self.init(compactSerializedString: compactSerializedString)
    }

    var compactSerializedData: Data {
        get throws {
            let serializedHeader = try JWT.encoder.encode(header)
            let serializedPayload = try JWT.encoder.encode(payload)

            return [
                serializedHeader.base64URLEncoded()!,
                JWT.dot,
                serializedPayload.base64URLEncoded()!,
                JWT.dot,
                signature.isEmpty ? nil : signature.base64URLEncoded()!
            ].compactMap({ $0 }).reduce(into: Data(), { $0 += $1 })
        }
    }

    var compactSerializedString: String {
        get throws {
            String(data: try compactSerializedData, encoding: .utf8)!
        }
    }
}

// MARK: JWS+validated

public extension JWS {
    func validated(using validator: some JWSValidator) throws -> JWS? {
        guard try validator.validate(self) else {
            return nil
        }

        return self
    }
}
