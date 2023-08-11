import XCTest
import CryptoKit

@testable import JOSESwift

final class JWSTests: XCTestCase {
    private static let privateKeyData = Data(base64Encoded: "k6nv5cglDg7jLHMNUfNS/8Hg6kVjkmsJrT1ep00Xc+A=")!

    func test_compactSerialized_unsecure() throws {
        let expectedCompactSerializedJWS = """
        eyJhbGciOiJub25lIiwidHlwIjoiSldTIn0.eyJtZXNzYWdlIjoiSGVsbG8gV29ybGQhIn0.
        """

        let validator = NoneValidator()

        let header = JWT.Signing.Header(jwk: nil)
        let payload = ["message": "Hello World!"]
        let signer = NoneSigner()

        let jws = try JWS(header: header, payload: payload, signer: signer)

        let compactSerializedJWS = try jws.compactSerializedString

        XCTAssertEqual(compactSerializedJWS, expectedCompactSerializedJWS)
        XCTAssertNotNil(JWS<[String: String]>(compactSerializedString: compactSerializedJWS))
        XCTAssertNotNil(try JWS<[String: String]>(compactSerializedString: compactSerializedJWS)?.validated(using: validator))
    }

    func test_compactSerialized_es256() throws {
        let expectedCompactSerializedComponents = [
            "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXUyJ9",
            "eyJtZXNzYWdlIjoiSGVsbG8gV29ybGQhIn0"
        ]

        let privateKey = try P256.Signing.PrivateKey(rawRepresentation: Self.privateKeyData)
        let validator = ES256Validator(validationKey: privateKey.publicKey)

        let header = JWT.Signing.Header(jwk: nil)
        let payload = ["message": "Hello World!"]
        let signer = ES256Signer(signingKey: privateKey)

        let jws = try JWS(header: header, payload: payload, signer: signer)

        let compactSerializedJWS = try jws.compactSerializedString
        let compactSerializedComponents = compactSerializedJWS.compactSerializedComponents

        XCTAssertEqual(compactSerializedComponents.count, 3)
        XCTAssertEqual(compactSerializedComponents[0], expectedCompactSerializedComponents[0])
        XCTAssertEqual(compactSerializedComponents[1], expectedCompactSerializedComponents[1])
        XCTAssertNotNil(JWS<[String: String]>(compactSerializedString: compactSerializedJWS))
        XCTAssertNotNil(try JWS<[String: String]>(compactSerializedString: compactSerializedJWS)?.validated(using: validator))
    }

    func test_compactSerialized_es256_wihJWK() throws {
        let expectedCompactSerializedComponents = [
            "eyJhbGciOiJFUzI1NiIsImp3ayI6eyJjcnYiOiJQLTI1NiIsImt0eSI6IkVDIiwieCI6IjdydTRiaW5UT2tyX1h1WDJDNy1qdlkzZEFpc3lncXRhdFZzS1hITjA2bWsiLCJ5IjoiQmpqbVlhV1J0ZjV4aXpCQmg1LU1UbWV2MXpGeFdyMHZoakpPTmdVTmliRSJ9LCJ0eXAiOiJKV1MifQ",
            "eyJtZXNzYWdlIjoiSGVsbG8gV29ybGQhIn0"
        ]

        let privateKey = try P256.Signing.PrivateKey(rawRepresentation: Self.privateKeyData)
        let validator = ES256Validator(validationKey: privateKey.publicKey)

        let header = JWT.Signing.Header(jwk: privateKey.publicKey.jwkRepresentation)
        let signer = ES256Signer(signingKey: privateKey)
        let payload = ["message": "Hello World!"]

        let jws = try JWS(header: header, payload: payload, signer: signer)

        let compactSerializedJWS = try jws.compactSerializedString
        let compactSerializedComponents = compactSerializedJWS.compactSerializedComponents

        XCTAssertEqual(compactSerializedComponents.count, 3)
        XCTAssertEqual(compactSerializedComponents[0], expectedCompactSerializedComponents[0])
        XCTAssertEqual(compactSerializedComponents[1], expectedCompactSerializedComponents[1])
        XCTAssertNotNil(JWS<[String: String]>(compactSerializedString: compactSerializedJWS))
        XCTAssertNotNil(try JWS<[String: String]>(compactSerializedString: compactSerializedJWS)?.validated(using: validator))
    }
}
