import Vapor
import JSONWebKey
import JSONWebToken
import JSONWebSignature

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

extension JWK: Content {}

struct JWTPayload: Content {
    let message: String
}

extension JWTPayload: JWTRegisteredFieldsClaims {
    var issuer: String? { nil }
    var subject: String? { nil }
    var audience: [String]? { nil }
    var expirationTime: Date? { nil }
    var notBeforeTime: Date? { nil }
    var issuedAt: Date? { nil }
    var jwtID: String? { nil }

    func validateExtraClaims() throws {}
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

    app.get("asymmetric", "signing", "jwk") { req async throws -> JWK in
        privateSigningKey.publicKey.jwkRepresentation
    }

    app.get("asymmetric", "encryption", "jwk") { req async throws -> JWK in
        privateKeyAgreementKey.publicKey.jwkRepresentation
    }

    app.post("asymmetric", "signing") { req async throws -> String in
        let jwtString = req.body.string ?? ""
        let verifiedJWT = try JWT<JWTPayload>.verify(jwtString: jwtString)
        let verifiedPayload = verifiedJWT.payload

        let seenPayload = JWTPayload(message: "\(verifiedPayload.message) (seen)")

        return try JWT.signed(
            payload: seenPayload,
            protectedHeader: DefaultJWSHeaderImpl(algorithm: .ES256),
            key: privateSigningKey.jwkRepresentation
        ).jwtString
    }
}
