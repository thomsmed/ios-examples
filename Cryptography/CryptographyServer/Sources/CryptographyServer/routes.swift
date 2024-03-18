import Vapor

struct SharedSymmetricRequest: Content {
    let message: Data
}

struct SharedSymmetricResponse: Content {
    let message: Data
}

struct SharedSymmetricAuthenticityRequest: Content {
    let header: Data
    let nonce: Data
    let cipherText: Data
    let tag: Data
}

struct SharedSymmetricAuthenticityResponse: Content {
    let header: Data
    let nonce: Data
    let cipherText: Data
    let tag: Data
}

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.post("symmetric", "shared") { req async throws -> SharedSymmetricResponse in
        // A shared symmetric key can be generated like so:
        // SymmetricKey(size: .bits256).withUnsafeBytes { buffer in
        //     let rawBase64KeyData = Data(buffer).base64EncodedString()
        //     print(rawBase64KeyData)
        // }

        let sharedSymmetricKeyData = Data(base64Encoded: "cE4AVV6G/9ft+jW8ofIosuiGhGA50/ZhHDtjTDfEdII=")!

        let symmetricKey = SymmetricKey(data: sharedSymmetricKeyData)

        let decodedRequest = try req.content.decode(SharedSymmetricRequest.self)

        let receivedSealedBox = try AES.GCM.SealedBox(combined: decodedRequest.message)

        let plainText = try AES.GCM.open(receivedSealedBox, using: symmetricKey)

        let message = String(data: plainText, encoding: .utf8)! + " (seen)"

        let sealedBox = try AES.GCM.seal(message.data(using: .utf8)!, using: symmetricKey)

        return SharedSymmetricResponse(message: sealedBox.combined!)
    }

    app.post("symmetric", "shared", "authenticity") { req async throws -> SharedSymmetricAuthenticityResponse in
        // A shared symmetric key can be generated like so:
        // SymmetricKey(size: .bits256).withUnsafeBytes { buffer in
        //     let rawBase64KeyData = Data(buffer).base64EncodedString()
        //     print(rawBase64KeyData)
        // }

        let sharedSymmetricKeyData = Data(base64Encoded: "cE4AVV6G/9ft+jW8ofIosuiGhGA50/ZhHDtjTDfEdII=")!

        let symmetricKey = SymmetricKey(data: sharedSymmetricKeyData)

        let requestPayload = try req.content.decode(SharedSymmetricAuthenticityRequest.self)

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

        return SharedSymmetricAuthenticityResponse(
            header: header,
            nonce: Data(sealedBox.nonce),
            cipherText: sealedBox.ciphertext,
            tag: sealedBox.tag
        )
    }
}
