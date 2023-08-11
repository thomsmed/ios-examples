import Vapor
import JOSESwift

// MARK: Requests and Responses

struct SharedSymmetricKeyRequest: Content {
    let message: Data
}

struct SharedSymmetricKeyResponse: Content {
    let message: Data
}

struct SharedSymmetricKeyAuthenticityRequest: Content {
    let header: Data
    let nonce: Data
    let cipherText: Data
    let tag: Data
}

struct SharedSymmetricKeyAuthenticityResponse: Content {
    let header: Data
    let nonce: Data
    let cipherText: Data
    let tag: Data
}

struct DerivedSymmetricKeyRequest: Content {
    let serializedPublicKey: String
    let message: Data
}

struct DerivedSymmetricKeyResponse: Content {
    let message: Data
}

struct DerivedSymmetricKeyAuthenticityRequest: Content {
    let serializedPublicKey: String
    let header: Data
    let nonce: Data
    let cipherText: Data
    let tag: Data
}

struct DerivedSymmetricKeyAuthenticityResponse: Content {
    let header: Data
    let nonce: Data
    let cipherText: Data
    let tag: Data
}

struct JWTPayload: Content {
    let message: String
}

// MARK: Cryptographic Keys

let privateSigningKey = P256.Signing.PrivateKey()
let privateKeyAgreementKey = P256.KeyAgreement.PrivateKey()

// MARK: Routes

func routes(_ app: Application) throws {

    // MARK: JWKs

    app.get("jwk", "signing") { req async throws -> String in
        privateSigningKey.publicKey.jwkRepresentation.serializedString
    }

    app.get("jwk", "encryption") { req async throws -> String in
        privateKeyAgreementKey.publicKey.jwkRepresentation.serializedString
    }

    // MARK: Symmetric Cryptography

    app.post("symmetric", "shared") { req async throws -> SharedSymmetricKeyResponse in
        // A shared symmetric key can be generated like so:
        // SymmetricKey(size: .bits256).withUnsafeBytes { buffer in
        //     let rawBase64KeyData = Data(buffer).base64EncodedString()
        //     print(rawBase64KeyData)
        // }

        let sharedSymmetricKeyData = Data(base64Encoded: "cE4AVV6G/9ft+jW8ofIosuiGhGA50/ZhHDtjTDfEdII=")!

        let symmetricKey = SymmetricKey(data: sharedSymmetricKeyData)

        let requestPayload = try req.content.decode(SharedSymmetricKeyRequest.self)

        let receivedSealedBox = try AES.GCM.SealedBox(combined: requestPayload.message)

        let plainText = try AES.GCM.open(receivedSealedBox, using: symmetricKey)

        let message = String(data: plainText, encoding: .utf8)! + " (seen)"

        let sealedBox = try AES.GCM.seal(message.data(using: .utf8)!, using: symmetricKey)

        return SharedSymmetricKeyResponse(message: sealedBox.combined!)
    }

    app.post("symmetric", "shared", "authenticity") { req async throws -> SharedSymmetricKeyAuthenticityResponse in
        // A shared symmetric key can be generated like so:
        // SymmetricKey(size: .bits256).withUnsafeBytes { buffer in
        //     let rawBase64KeyData = Data(buffer).base64EncodedString()
        //     print(rawBase64KeyData)
        // }

        let sharedSymmetricKeyData = Data(base64Encoded: "cE4AVV6G/9ft+jW8ofIosuiGhGA50/ZhHDtjTDfEdII=")!

        let symmetricKey = SymmetricKey(data: sharedSymmetricKeyData)

        let requestPayload = try req.content.decode(SharedSymmetricKeyAuthenticityRequest.self)

        let receivedSealedBox = try AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: requestPayload.nonce),
            ciphertext: requestPayload.cipherText,
            tag: requestPayload.tag
        )

        let plainText = try AES.GCM.open(
            receivedSealedBox,
            using: symmetricKey,
            authenticating: requestPayload.header
        )

        let message = String(data: plainText, encoding: .utf8)! + " (seen)"

        let header = "<server-authenticity-header>".data(using: .utf8)!
        let sealedBox = try AES.GCM.seal(
            message.data(using: .utf8)!,
            using: symmetricKey,
            authenticating: header
        )

        return SharedSymmetricKeyAuthenticityResponse(
            header: header,
            nonce: Data(sealedBox.nonce),
            cipherText: sealedBox.ciphertext,
            tag: sealedBox.tag
        )
    }

    app.post("symmetric", "derived") { req async throws -> DerivedSymmetricKeyResponse in
        let requestPayload = try req.content.decode(DerivedSymmetricKeyRequest.self)

        let jwk = JWK(serialized: requestPayload.serializedPublicKey)!

        let clientPublicKey = P256.KeyAgreement.PublicKey(jwkRepresentation: jwk)!

        let sharedSecret = try privateKeyAgreementKey.sharedSecretFromKeyAgreement(with: clientPublicKey)

        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data(),
            outputByteCount: 256 / 8
        )

        assert(symmetricKey.bitCount == 256)

        let receivedSealedBox = try AES.GCM.SealedBox(combined: requestPayload.message)

        let plainText = try AES.GCM.open(receivedSealedBox, using: symmetricKey)

        let message = String(data: plainText, encoding: .utf8)! + " (seen)"

        let sealedBox = try AES.GCM.seal(message.data(using: .utf8)!, using: symmetricKey)

        return DerivedSymmetricKeyResponse(message: sealedBox.combined!)
    }

    app.post("symmetric", "derived", "authenticity") { req async throws -> DerivedSymmetricKeyAuthenticityResponse in
        let requestPayload = try req.content.decode(DerivedSymmetricKeyAuthenticityRequest.self)

        let jwk = JWK(serialized: requestPayload.serializedPublicKey)!

        let clientPublicKey = P256.KeyAgreement.PublicKey(jwkRepresentation: jwk)!

        let sharedSecret = try privateKeyAgreementKey.sharedSecretFromKeyAgreement(with: clientPublicKey)

        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data(),
            outputByteCount: 256 / 8
        )

        assert(symmetricKey.bitCount == 256)

        let receivedSealedBox = try AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: requestPayload.nonce),
            ciphertext: requestPayload.cipherText,
            tag: requestPayload.tag
        )

        let plainText = try AES.GCM.open(
            receivedSealedBox,
            using: symmetricKey,
            authenticating: requestPayload.header
        )

        let message = String(data: plainText, encoding: .utf8)! + " (seen)"

        let header = "<server-authenticity-header>".data(using: .utf8)!
        let sealedBox = try AES.GCM.seal(
            message.data(using: .utf8)!,
            using: symmetricKey,
            authenticating: header
        )

        return DerivedSymmetricKeyAuthenticityResponse(
            header: header,
            nonce: Data(sealedBox.nonce),
            cipherText: sealedBox.ciphertext,
            tag: sealedBox.tag
        )
    }

    // MARK: Asymmetric Cryptography

    app.post("asymmetric", "signing") { req async throws -> String in
        let jws = JWS<JWTPayload>(compactSerializedString: req.body.string!)!

        let jwk = jws.header.jwk!

        let publicKey = P256.Signing.PublicKey(jwkRepresentation: jwk)!

        let validatedJWS = try jws.validated(using: ES256Validator(validationKey: publicKey))!

        let header = JWT.Signing.Header(jwk: nil)
        let seenPayload = JWTPayload(message: "\(validatedJWS.payload.message) (seen)")
        let signer = ES256Signer(signingKey: privateSigningKey)

        return try JWS(
            header: header,
            payload: seenPayload,
            signer: signer
        ).compactSerializedString
    }

    app.post("asymmetric", "encryption") { req async throws -> String in
        "TODO: Fix Me!"
    }
}
