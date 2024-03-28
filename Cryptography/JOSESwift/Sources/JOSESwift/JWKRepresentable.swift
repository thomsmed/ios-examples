//
//  JWKRepresentable.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 28/03/2024.
//

import Foundation
import CryptoKit

// MARK: JWKRepresentable

public protocol JWKRepresentable {
    init?(jwkRepresentation: JWK)
    var jwkRepresentation: JWK { get }
}

// MARK: Signing

extension P256.Signing.PrivateKey: JWKRepresentable {
    public init?(jwkRepresentation: JWK) {
        guard
            let d = jwkRepresentation.d,
            let data = Data(base64URLEncoded: d)
        else {
            return nil
        }

        try? self.init(rawRepresentation: data)
    }

    public var jwkRepresentation: JWK {
        let publicKeyRawRepresentation = publicKey.rawRepresentation
        let x = publicKeyRawRepresentation.prefix(publicKeyRawRepresentation.count / 2)
        let y = publicKeyRawRepresentation.suffix(publicKeyRawRepresentation.count / 2)
        return JWK.EC256(
            kid: nil,
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: rawRepresentation.base64URLEncodedString()
        )
    }
}

extension P256.Signing.PublicKey: JWKRepresentable {
    public init?(jwkRepresentation: JWK) {
        guard
            let xData = Data(base64URLEncoded: jwkRepresentation.x),
            let yData = Data(base64URLEncoded: jwkRepresentation.y)
        else {
            return nil
        }

        try? self.init(rawRepresentation: xData + yData)
    }

    public var jwkRepresentation: JWK {
        let x = rawRepresentation.prefix(rawRepresentation.count / 2)
        let y = rawRepresentation.suffix(rawRepresentation.count / 2)
        return JWK.EC256(
            kid: nil,
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: nil
        )
    }
}

extension P384.Signing.PrivateKey: JWKRepresentable {
    public init?(jwkRepresentation: JWK) {
        guard
            let d = jwkRepresentation.d,
            let data = Data(base64URLEncoded: d)
        else {
            return nil
        }

        try? self.init(rawRepresentation: data)
    }

    public var jwkRepresentation: JWK {
        let publicKeyRawRepresentation = publicKey.rawRepresentation
        let x = publicKeyRawRepresentation.prefix(publicKeyRawRepresentation.count / 2)
        let y = publicKeyRawRepresentation.suffix(publicKeyRawRepresentation.count / 2)
        return JWK.EC256(
            kid: nil,
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: rawRepresentation.base64URLEncodedString()
        )
    }
}

extension P384.Signing.PublicKey: JWKRepresentable {
    public init?(jwkRepresentation: JWK) {
        guard
            let xData = Data(base64URLEncoded: jwkRepresentation.x),
            let yData = Data(base64URLEncoded: jwkRepresentation.y)
        else {
            return nil
        }

        try? self.init(rawRepresentation: xData + yData)
    }

    public var jwkRepresentation: JWK {
        let x = rawRepresentation.prefix(rawRepresentation.count / 2)
        let y = rawRepresentation.suffix(rawRepresentation.count / 2)
        return JWK.EC256(
            kid: nil,
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: nil
        )
    }
}

extension P521.Signing.PrivateKey: JWKRepresentable {
    public init?(jwkRepresentation: JWK) {
        guard
            let d = jwkRepresentation.d,
            let data = Data(base64URLEncoded: d)
        else {
            return nil
        }

        try? self.init(rawRepresentation: data)
    }

    public var jwkRepresentation: JWK {
        let publicKeyRawRepresentation = publicKey.rawRepresentation
        let x = publicKeyRawRepresentation.prefix(publicKeyRawRepresentation.count / 2)
        let y = publicKeyRawRepresentation.suffix(publicKeyRawRepresentation.count / 2)
        return JWK.EC256(
            kid: nil,
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: rawRepresentation.base64URLEncodedString()
        )
    }
}

extension P521.Signing.PublicKey: JWKRepresentable {
    public init?(jwkRepresentation: JWK) {
        guard
            let xData = Data(base64URLEncoded: jwkRepresentation.x),
            let yData = Data(base64URLEncoded: jwkRepresentation.y)
        else {
            return nil
        }

        try? self.init(rawRepresentation: xData + yData)
    }

    public var jwkRepresentation: JWK {
        let x = rawRepresentation.prefix(rawRepresentation.count / 2)
        let y = rawRepresentation.suffix(rawRepresentation.count / 2)
        return JWK.EC256(
            kid: nil,
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: nil
        )
    }
}

// MARK: KeyAgreement

extension P256.KeyAgreement.PrivateKey: JWKRepresentable {
    public init?(jwkRepresentation: JWK) {
        guard
            let d = jwkRepresentation.d,
            let data = Data(base64URLEncoded: d)
        else {
            return nil
        }

        try? self.init(rawRepresentation: data)
    }

    public var jwkRepresentation: JWK {
        let publicKeyRawRepresentation = publicKey.rawRepresentation
        let x = publicKeyRawRepresentation.prefix(publicKeyRawRepresentation.count / 2)
        let y = publicKeyRawRepresentation.suffix(publicKeyRawRepresentation.count / 2)
        return JWK.EC256(
            kid: nil,
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: rawRepresentation.base64URLEncodedString()
        )
    }
}

extension P256.KeyAgreement.PublicKey: JWKRepresentable {
    public init?(jwkRepresentation: JWK) {
        guard
            let xData = Data(base64URLEncoded: jwkRepresentation.x),
            let yData = Data(base64URLEncoded: jwkRepresentation.y)
        else {
            return nil
        }

        try? self.init(rawRepresentation: xData + yData)
    }

    public var jwkRepresentation: JWK {
        let x = rawRepresentation.prefix(rawRepresentation.count / 2)
        let y = rawRepresentation.suffix(rawRepresentation.count / 2)
        return JWK.EC256(
            kid: nil,
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: nil
        )
    }
}

extension P384.KeyAgreement.PrivateKey: JWKRepresentable {
    public init?(jwkRepresentation: JWK) {
        guard
            let d = jwkRepresentation.d,
            let data = Data(base64URLEncoded: d)
        else {
            return nil
        }

        try? self.init(rawRepresentation: data)
    }

    public var jwkRepresentation: JWK {
        let publicKeyRawRepresentation = publicKey.rawRepresentation
        let x = publicKeyRawRepresentation.prefix(publicKeyRawRepresentation.count / 2)
        let y = publicKeyRawRepresentation.suffix(publicKeyRawRepresentation.count / 2)
        return JWK.EC256(
            kid: nil,
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: rawRepresentation.base64URLEncodedString()
        )
    }
}

extension P384.KeyAgreement.PublicKey: JWKRepresentable {
    public init?(jwkRepresentation: JWK) {
        guard
            let xData = Data(base64URLEncoded: jwkRepresentation.x),
            let yData = Data(base64URLEncoded: jwkRepresentation.y)
        else {
            return nil
        }

        try? self.init(rawRepresentation: xData + yData)
    }

    public var jwkRepresentation: JWK {
        let x = rawRepresentation.prefix(rawRepresentation.count / 2)
        let y = rawRepresentation.suffix(rawRepresentation.count / 2)
        return JWK.EC256(
            kid: nil,
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: nil
        )
    }
}

extension P521.KeyAgreement.PrivateKey: JWKRepresentable {
    public init?(jwkRepresentation: JWK) {
        guard
            let d = jwkRepresentation.d,
            let data = Data(base64URLEncoded: d)
        else {
            return nil
        }

        try? self.init(rawRepresentation: data)
    }

    public var jwkRepresentation: JWK {
        let publicKeyRawRepresentation = publicKey.rawRepresentation
        let x = publicKeyRawRepresentation.prefix(publicKeyRawRepresentation.count / 2)
        let y = publicKeyRawRepresentation.suffix(publicKeyRawRepresentation.count / 2)
        return JWK.EC256(
            kid: nil,
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: rawRepresentation.base64URLEncodedString()
        )
    }
}

extension P521.KeyAgreement.PublicKey: JWKRepresentable {
    public init?(jwkRepresentation: JWK) {
        guard
            let xData = Data(base64URLEncoded: jwkRepresentation.x),
            let yData = Data(base64URLEncoded: jwkRepresentation.y)
        else {
            return nil
        }

        try? self.init(rawRepresentation: xData + yData)
    }

    public var jwkRepresentation: JWK {
        let x = rawRepresentation.prefix(rawRepresentation.count / 2)
        let y = rawRepresentation.suffix(rawRepresentation.count / 2)
        return JWK.EC256(
            kid: nil,
            x: x.base64URLEncodedString(),
            y: y.base64URLEncodedString(),
            d: nil
        )
    }
}
