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

struct JWTPayload: Content {
    let message: String
}

// MARK: Cryptographic Keys

let privateSigningKey = P256.Signing.PrivateKey()
let privateKeyAgreementKey = P256.KeyAgreement.PrivateKey()

// MARK: Routes

func routes(_ app: Application) throws {
    app.post("symmetric", "shared") { req async throws -> SharedSymmetricKeyResponse in
        // A shared symmetric key can be generated like so:
        // SymmetricKey(size: .bits256).withUnsafeBytes { buffer in
        //     let rawBase64KeyData = Data(buffer).base64EncodedString()
        //     print(rawBase64KeyData)
        // }

        let sharedSymmetricKeyData = Data(base64Encoded: "cE4AVV6G/9ft+jW8ofIosuiGhGA50/ZhHDtjTDfEdII=")!

        let symmetricKey = SymmetricKey(data: sharedSymmetricKeyData)

        let decodedRequest = try req.content.decode(SharedSymmetricKeyRequest.self)

        let receivedSealedBox = try AES.GCM.SealedBox(combined: decodedRequest.message)

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

        let header = "<server-header>".data(using: .utf8)!
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

    app.get("asymmetric", "signing", "jwk") { req async throws -> String in
        privateSigningKey.publicKey.jwkRepresentation.serializedString
    }

    app.get("asymmetric", "encryption", "jwk") { req async throws -> String in
        privateKeyAgreementKey.publicKey.jwkRepresentation.serializedString
    }

    app.post("asymmetric", "signing") { req async throws -> String in
        guard
            let compactSerializedString = req.body.string,
            let jws = JWS<JWTPayload>(compactSerializedString: compactSerializedString)
        else {
            return "TODO: Fix Me!"
        }

        guard let jwk = jws.header.jwk else {
            return "TODO: Fix Me!"
        }

        guard let publicKey = P256.Signing.PublicKey(jwkRepresentation: jwk) else {
            return "TODO: Fix Me!"
        }

        guard let validatedJWS = try jws.validated(using: ES256Validator(validationKey: publicKey)) else {
            return "TODO: Fix Me!"
        }

        let seenPayload = JWTPayload(message: "\(validatedJWS.payload.message) (seen)")
        let signer = ES256Signer(signingKey: privateSigningKey)
        let header = JWT.Signing.Header(algorithm: signer.algorithm, jwk: nil)

        return try JWS(
            header: header,
            payload: seenPayload,
            signer: signer
        ).compactSerializedString
    }
}
