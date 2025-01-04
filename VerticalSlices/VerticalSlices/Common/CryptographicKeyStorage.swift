//
//  CryptographicKeyStorage.swift
//  VerticalSlices
//
//  Created by Thomas Asheim Smedmann on 21/10/2024.
//

import Foundation
import OSLog

// MARK: Logger extensions

public extension Logger {
    static let cryptographicKeyStorage = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "CryptographicKeyStorage"
    )
}

// MARK: ManagedCryptographicKey

public struct EC256KeyPair {
    public let privateKey: SecKey
    public let publicKey: SecKey

    fileprivate init?(privateKey: SecKey) {
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            return nil
        }

        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}

public enum ManagedCryptographicKeyAccessControl: Sendable {
    case none
    case userPresence
}

/// Protocol representing something that is a Cryptographic Key that should be managed by``CryptographicKeyStorage``.
public protocol ManagedCryptographicKey {
    static var namespace: String { get }
    static var tag: String { get }
    static var accessControl: ManagedCryptographicKeyAccessControl { get }

    init(_ keyPair: EC256KeyPair)
}

internal extension ManagedCryptographicKey {
    static var combinedTag: Data { Data((Self.namespace + "." + Self.tag).utf8) }
}

// MARK: CryptographicKeyStorage

public enum CryptographicKeyStorageError: Error {
    case secureEnclaveUnavailable
    case keyExistWithTag
    case failedToCreateKeyAccessControl
    case failedToCreateKey
    case failedToGetKey
    case unexpectedError(Int)
}

/// Protocol representing I/O operations around managed Cryptographic Keys (typically by the Secure Enclave).
public protocol CryptographicKeyStorage: Sendable {
    func getOrCreate<Key: ManagedCryptographicKey>() throws(CryptographicKeyStorageError) -> Key
    func get<Key: ManagedCryptographicKey>() throws(CryptographicKeyStorageError) -> Key?
    func delete<Key: ManagedCryptographicKey>(_: Key.Type) throws(CryptographicKeyStorageError)
}

// MARK: TestCryptographicKeyStorage

public final class TestCryptographicKeyStorage: @unchecked Sendable, CryptographicKeyStorage {
    private var storage: [Data: EC256KeyPair] = [:]

    public init() {}

    private func makeInMemoryKey() -> EC256KeyPair {
        let attributes = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrCanSign as String: true
        ] as [String: Any]

        return EC256KeyPair(privateKey: SecKeyCreateRandomKey(attributes as CFDictionary, nil)!)!
    }

    public func getOrCreate<Key: ManagedCryptographicKey>() throws(CryptographicKeyStorageError) -> Key {
        Logger.cryptographicKeyStorage.warning("You are using \(String(describing: Self.self))")

        if let existingKeyPair = storage[Key.combinedTag]{
            return Key(existingKeyPair)
        }
        let newKeyPair = makeInMemoryKey()
        storage[Key.combinedTag] = newKeyPair
        return Key(newKeyPair)
    }

    public func get<Key: ManagedCryptographicKey>() throws(CryptographicKeyStorageError) -> Key? {
        Logger.cryptographicKeyStorage.warning("You are using \(String(describing: Self.self))")

        guard let keyPair = storage[Key.combinedTag] else {
            return nil
        }
        return Key(keyPair)
    }

    public func delete<Key: ManagedCryptographicKey>(_: Key.Type) throws(CryptographicKeyStorageError) {
        Logger.cryptographicKeyStorage.warning("You are using \(String(describing: Self.self))")

        return storage[Key.combinedTag] = nil
    }
}

// MARK: SecureCryptographicKeyStorage

/// A general storage for EC key pairs protected by Secure Enclave.
///
/// The generated and stored keys are protected by Secure Enclave,
/// hence only NIST P-256 elliptic curve key pairs are supported.
///
/// These keys can only be used for creating and verifying cryptographic signatures,
/// or for elliptic curve Diffie-Hellman key exchange (and by extension, symmetric encryption).
public final class SecureCryptographicKeyStorage {
    public init() {}

    /// Generate a NIST P-256 elliptic curve key pair.
    /// Protected by Secure Enclave and stored securely in the keychain.
    /// - Parameter tag: A tag used to identify the key pair. The tag should be unique per key pair.
    /// - Returns: The private key of the newly generated key pair.
    private func getOrCreateKey(
        withTag tag: Data,
        andAccessControl keyAccessControl: ManagedCryptographicKeyAccessControl
    ) throws(CryptographicKeyStorageError) -> EC256KeyPair {
#if targetEnvironment(simulator)
        // Simulators do not have SecureEnclave.
#else
        guard SecureEnclave.isAvailable else {
            throw CryptographicKeyStorageError.secureEnclaveUnavailable
        }
#endif

        if let existingKey = try getKey(withTag: tag) {
            return existingKey
        }

        var error: Unmanaged<CFError>?
        let flags: SecAccessControlCreateFlags = switch keyAccessControl {
            case .none:
                [
                    // Enable the private key to be used in signing operations inside Secure Enclave.
                    .privateKeyUsage,
                ]
            case .userPresence:
                [
                    // Enable the private key to be used in signing operations inside Secure Enclave.
                    .privateKeyUsage,

                    // Require user presence by device passcode or biometry input.
                    .userPresence
                ]
        }
        guard let accessControl = SecAccessControlCreateWithFlags(
            // Allocator.
            kCFAllocatorDefault,

            // Protection class.
            // Ensure key(s) is only available when the device is unlocked,
            // and will never move to another device (e.g restoring from backup on another device).
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,

            // Flags.
            flags,

            // Error.
            &error
        ) else {
            throw CryptographicKeyStorageError.failedToCreateKeyAccessControl
        }

#if targetEnvironment(simulator)
        // Simulators do not have SecureEnclave.
        let attributes = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecPrivateKeyAttrs as String: [
                kSecAttrCanSign as String: true,
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag,
                kSecAttrAccessControl as String: accessControl,
            ] as [String: Any]
        ] as [String: Any]
#else
        let attributes = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrCanSign as String: true,
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag,
                kSecAttrAccessControl as String: accessControl,
            ] as [String: Any],
        ] as [String : Any]
#endif

        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw CryptographicKeyStorageError.failedToCreateKey
        }

        guard let keyPair = EC256KeyPair(privateKey: privateKey) else {
            throw CryptographicKeyStorageError.failedToCreateKey
        }

        return keyPair
    }

    /// Get the private key of a NIST P-256 elliptic curve key pair.
    /// - Parameter tag: The tag that identifies the key pair this private key is part of.
    /// - Returns:The private key of the key pair identified with the given tag.
    private func getKey(withTag tag: Data) throws(CryptographicKeyStorageError) -> EC256KeyPair? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            if status == errSecUnknownTag || status == errSecItemNotFound {
                return nil
            } else {
                throw CryptographicKeyStorageError.failedToGetKey
            }
        }

        // This force cast will always success if status == errSecSuccess
        let privateKey = item as! SecKey

        return EC256KeyPair(privateKey: privateKey)
    }

    /// Delete a previously generated NIST P-256 elliptic curve key pair.
    /// - Parameter tag: The tag that identifies the key pair.
    public func deleteKey(withTag tag: Data) throws(CryptographicKeyStorageError) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw CryptographicKeyStorageError.unexpectedError(Int(status))
        }
    }
}

extension SecureCryptographicKeyStorage: CryptographicKeyStorage {
    /// Generate a NIST P-256 elliptic curve key pair.
    /// Protected by Secure Enclave and stored securely in the keychain.
    /// - Returns: The private key of the newly generated key pair.
    public func getOrCreate<Key: ManagedCryptographicKey>() throws(CryptographicKeyStorageError) -> Key {
        Key(try getOrCreateKey(withTag: Key.combinedTag, andAccessControl: Key.accessControl))
    }


    /// Get the private key of a NIST P-256 elliptic curve key pair.
    /// - Parameter tag: The tag that identifies the key pair this private key is part of.
    /// - Returns:The private key of the key pair identified with the given tag.
    public func get<Key: ManagedCryptographicKey>() throws(CryptographicKeyStorageError) -> Key? {
        guard let keyPair = try getKey(withTag: Key.combinedTag) else {
            return nil
        }
        return Key(keyPair)
    }

    /// Delete a previously generated NIST P-256 elliptic curve key pair.
    /// - Parameter tag: The tag that identifies the key pair.
    public func delete<Key: ManagedCryptographicKey>(_: Key.Type) throws(CryptographicKeyStorageError) {
        try deleteKey(withTag: Key.combinedTag)
    }
}

// MARK: Exposing CryptographicKeyStorage to SwiftUI

import SwiftUI

public extension EnvironmentValues {
    @Entry var cryptographicKeyStorage: CryptographicKeyStorage = TestCryptographicKeyStorage()
}

public extension View {
    func cryptographicKeyStorage(_ cryptographicKeyStorage: CryptographicKeyStorage) -> some View {
        environment(\.cryptographicKeyStorage, cryptographicKeyStorage)
    }
}

/// A custom convenience property wrapper adhering to DynamicProperty.
@MainActor @propertyWrapper public struct ProtectedCryptographicKey<Value: ManagedCryptographicKey>: DynamicProperty {
    @Environment(\.cryptographicKeyStorage) private var cryptographicKeyStorage

    public init() {}

    public var wrappedValue: Value? {
        try? cryptographicKeyStorage.getOrCreate()
    }
}
