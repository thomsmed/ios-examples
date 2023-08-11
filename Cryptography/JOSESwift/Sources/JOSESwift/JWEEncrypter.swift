//
//  JWEEncrypter.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 28/03/2024.
//

import Foundation
import CryptoKit

public protocol JWEEncrypter {
    func encrypt<Payload: Codable>(_ header: JWT.Encryption.Header, payload: Payload) throws -> JWE<Payload>
}

// MARK: DirectEncrypter

public struct DirectEncrypter: JWEEncrypter {
    public let contentEncryptionAlgorithm: JWT.Encryption.ContentEncryptionAlgorithm
    public let symmetricKey: SymmetricKey

    public init(
        contentEncryptionAlgorithm: JWT.Encryption.ContentEncryptionAlgorithm,
        symmetricKey: SymmetricKey
    ) {
        assert(symmetricKey.bitCount == contentEncryptionAlgorithm.bitCount)

        self.contentEncryptionAlgorithm = contentEncryptionAlgorithm
        self.symmetricKey = symmetricKey
    }

    public func encrypt<Payload: Codable>(_ header: JWT.Encryption.Header, payload: Payload) throws -> JWE<Payload> {
        var header = header
        header.alg = .dir

        switch contentEncryptionAlgorithm {
            case .A128GCM:
                header.enc = .A128GCM
            case .A192GCM:
                header.enc = .A192GCM
            case .A256GCM:
                header.enc = .A256GCM
        }

        let data = try JWT.encoder.encode(payload)
        let additionalData = try JWT.encoder.encode(header)

        let sealedBox = try AES.GCM.seal(
            data,
            using: symmetricKey,
            nonce: nil,
            authenticating: additionalData
        )

        return JWE(
            header: header,
            encryptedKey: Data(),
            initializationVector: Data(sealedBox.nonce),
            cipherText: sealedBox.ciphertext,
            authenticationTag: sealedBox.tag
        )
    }
}

// MARK: ECDHES256Encrypter

public struct ECDHES256Encrypter: JWEEncrypter {
    public let contentEncryptionAlgorithm: JWT.Encryption.ContentEncryptionAlgorithm
    public let remoteKeyAgreementKey: P256.KeyAgreement.PublicKey

    public init(
        contentEncryptionAlgorithm: JWT.Encryption.ContentEncryptionAlgorithm,
        remoteKeyAgreementKey: P256.KeyAgreement.PublicKey
    ) {
        assert(remoteKeyAgreementKey.bitCount == contentEncryptionAlgorithm.bitCount)

        self.contentEncryptionAlgorithm = contentEncryptionAlgorithm
        self.remoteKeyAgreementKey = remoteKeyAgreementKey
    }

    public func encrypt<Payload: Codable>(_ header: JWT.Encryption.Header, payload: Payload) throws -> JWE<Payload> {
        var header = header
        header.alg = .ECDHES

        switch contentEncryptionAlgorithm {
            case .A128GCM, .A192GCM, .A256GCM:
                header.enc = .A256GCM

                let data = try JWT.encoder.encode(payload)
                let additionalData = try JWT.encoder.encode(header)

                let privateKey = P256.KeyAgreement.PrivateKey()
                let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: remoteKeyAgreementKey)

                let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
                    using: SHA256.self,
                    salt: Data(),
                    sharedInfo: Data(),
                    outputByteCount: contentEncryptionAlgorithm.bitCount / 8
                )

                let sealedBox = try AES.GCM.seal(
                    data,
                    using: symmetricKey,
                    nonce: nil,
                    authenticating: additionalData
                )

                return JWE(
                    header: header,
                    encryptedKey: Data(),
                    initializationVector: Data(sealedBox.nonce),
                    cipherText: sealedBox.ciphertext,
                    authenticationTag: sealedBox.tag
                )
        }
    }
}
