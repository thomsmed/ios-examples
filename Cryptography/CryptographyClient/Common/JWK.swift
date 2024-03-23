//
//  JWK.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 23/03/2024.
//

import Foundation
import CryptoKit

/// [JSON Web Key (JWK)](https://datatracker.ietf.org/doc/html/rfc7517).
struct JWK {
    let kty: String
    let crv: String
    let x: String
    let y: String
    let d: String? // For private keys only.
}

extension P256.Signing.PrivateKey {
    var jwkRepresentation: JWK {
        let publicKeyRawRepresentation = publicKey.rawRepresentation
        let x = publicKeyRawRepresentation.prefix(publicKeyRawRepresentation.count / 2)
        let y = publicKeyRawRepresentation.suffix(publicKeyRawRepresentation.count / 2)
        return JWK(
            kty: "EC",
            crv: "P-256",
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: rawRepresentation.base64URLEncodedString()
        )
    }
}

extension P256.Signing.PublicKey {
    var jwkRepresentation: JWK {
        let x = rawRepresentation.prefix(rawRepresentation.count / 2)
        let y = rawRepresentation.suffix(rawRepresentation.count / 2)
        return JWK(
            kty: "EC",
            crv: "P-256",
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: nil
        )
    }
}
