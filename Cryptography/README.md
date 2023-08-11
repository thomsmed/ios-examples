# Exploring Cryptography with iOS

Topics to explore:

- Secure Enclave
  - https://support.apple.com/en-gb/guide/security/sec59b0b31ff/web
- Storing Cryptographic Keys in the Keychain
- Hash functions
- Symmetric Key Cryptography
  - Block Cipher VS Streaming Cipher
  - AES / ChaCha
- Asymmetric (Public) Key Cryptography
  - RSA / Elliptic Curve
- Message Authentication Codes (HMAC)
- Certificate Pinning

## Cryptography Client (iOS) App

A simple SwiftUI iOS app exploring various cryptography concepts,
primarily using [Apple CryptoKit](https://developer.apple.com/documentation/cryptokit/).

Select the `CryptographyClient` scheme to build and run the iOS app.

Note: Works best in Simulator, as the accompanied Terminal/Server application listen on `localhost:8080`.

## Cryptography Server (Vapor) App

A simple Terminal/Server app acting as a Web Server, and accepting HTTP requests.

Built using [Vapor](https://docs.vapor.codes/).

```bash
# Instal the Vapor toolbox
brew install vapor

# Bootstrap a new Vapor based Swift Terminal/Server app
vapor new HelloVapor
```

Select the `CryptographyServer` scheme to build and run the Terminal/Server app.

Note: The Terminal/Server app is listening on `localhost:8080` by default.

## Simple JOSE Implementation

A simple JOSE library implementing a couple TODO: Bla bla.

## Utils

### Public key hash for TLS certificate pinning

A simple bash snippet to generate the public key hash of the TLS certificate of a remote server.

```bash
#!/bin/bash

# Generate a base 64 encoded string of the SubjectPublicKeyInfo part of a remote server's TLS certificate.
# This value is often used when pining against a remote server's Certificate (Public Key Pinning).

SERVERNAME="developer.apple.com";

openssl s_client -servername $SERVERNAME -connect $SERVERNAME:443 |
  openssl x509 -pubkey -noout |
  openssl rsa -pubin -outform der | # Optionally "openssl ec -pubin -outform der" if the key used in the Certificate is an Elliptic Curve.
  openssl dgst -sha256 -binary |
  openssl enc -base64
```

### JWK parameters for CryptoKit key(s)

The general idea is to inspect the raw representation of the key, like so:

```swift
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
```
