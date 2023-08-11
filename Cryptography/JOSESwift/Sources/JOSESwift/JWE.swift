//
//  JWE.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 23/03/2024.
//

import Foundation

/// [JSON Web Encryption (JWE)](https://datatracker.ietf.org/doc/html/rfc7516).
public struct JWE<Payload: Codable> {
    public let header: JWT.Encryption.Header
    public let encryptedKey: Data
    public let initializationVector: Data
    public let cipherText: Data
    public let authenticationTag: Data

    internal init(
        header: JWT.Encryption.Header,
        encryptedKey: Data,
        initializationVector: Data,
        cipherText: Data,
        authenticationTag: Data
    ) {
        self.header = header
        self.encryptedKey = encryptedKey
        self.initializationVector = initializationVector
        self.cipherText = cipherText
        self.authenticationTag = authenticationTag
    }
}

extension JWE {
    init(header: JWT.Encryption.Header, payload: Payload, encrypter: some JWEEncrypter) throws {
        self = try encrypter.encrypt(header, payload: payload)
    }
}

// MARK: JWE+compactSerialized

public extension JWE {
    init?(compactSerializedString: String) {
        let compactSerializedComponents = compactSerializedString.compactSerializedComponents

        guard compactSerializedComponents.count == 5 else {
            return nil
        }

        guard let headerData = Data(base64URLEncoded: compactSerializedComponents[0]) else {
            return nil
        }

        guard let header = try? JWT.decoder.decode(JWT.Encryption.Header.self, from: headerData) else {
            return nil
        }

        guard let encryptedKey = Data(base64URLEncoded: compactSerializedComponents[1]) else {
            return nil
        }

        guard let initializationVector = Data(base64URLEncoded: compactSerializedComponents[2]) else {
            return nil
        }

        guard let cipherText = Data(base64URLEncoded: compactSerializedComponents[3]) else {
            return nil
        }

        guard let authenticationTag = Data(base64URLEncoded: compactSerializedComponents[4]) else {
            return nil
        }

        self.header = header
        self.encryptedKey = encryptedKey
        self.initializationVector = initializationVector
        self.cipherText = cipherText
        self.authenticationTag = authenticationTag
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

            return [
                serializedHeader.base64URLEncoded()!,
                JWT.dot,
                encryptedKey.isEmpty ? nil : encryptedKey.base64URLEncoded()!,
                JWT.dot,
                initializationVector.isEmpty ? nil : initializationVector.base64URLEncoded()!,
                JWT.dot,
                cipherText.base64URLEncoded()!,
                JWT.dot,
                authenticationTag.isEmpty ? nil : authenticationTag.base64URLEncoded()!,
            ].compactMap({ $0 }).reduce(into: Data(), { $0 += $1 })
        }
    }

    var compactSerializedString: String {
        get throws {
            String(data: try compactSerializedData, encoding: .utf8)!
        }
    }
}

// MARK: JWE+decrypt

public extension JWE {
    func decrypt(using decrypter: some JWEDecrypter) throws -> Payload {
        try decrypter.decrypt(self)
    }
}
