import XCTest
import CryptoKit

@testable import JOSESwift

final class JWKTests: XCTestCase {
    private static let privateKeyData = Data(base64Encoded: "k6nv5cglDg7jLHMNUfNS/8Hg6kVjkmsJrT1ep00Xc+A=")!

    func test_serialized() throws {
        let expectedSerializedPrivateKeyString = """
        {"crv":"P-256","d":"k6nv5cglDg7jLHMNUfNS_8Hg6kVjkmsJrT1ep00Xc-A","kty":"EC","x":"7ru4binTOkr_XuX2C7-jvY3dAisygqtatVsKXHN06mk","y":"BjjmYaWRtf5xizBBh5-MTmev1zFxWr0vhjJONgUNibE"}
        """
        let expectedSerializedPublicKeyString = """
        {"crv":"P-256","kty":"EC","x":"7ru4binTOkr_XuX2C7-jvY3dAisygqtatVsKXHN06mk","y":"BjjmYaWRtf5xizBBh5-MTmev1zFxWr0vhjJONgUNibE"}
        """

        let privateKey = try P256.Signing.PrivateKey(rawRepresentation: Self.privateKeyData)

        let serializedPrivateKeyString = privateKey.jwkRepresentation.serializedString
        let serializedPublicKeyString = privateKey.publicKey.jwkRepresentation.serializedString

        XCTAssertEqual(serializedPrivateKeyString, expectedSerializedPrivateKeyString)
        XCTAssertEqual(serializedPublicKeyString, expectedSerializedPublicKeyString)
    }
}
