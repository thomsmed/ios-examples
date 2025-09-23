//
//  KeyVault.swift
//  EntityComponentSystem
//
//  Created by Thomas Smedmann on 22/09/2025.
//

import Foundation

protocol KeyVault {
    func get(_ entry: KeyVaultEntry<SecKey>) throws(KeyVaultError) -> SecKey?
    func create(_ entry: KeyVaultEntry<SecKey>) throws(KeyVaultError) -> SecKey
    func delete(_ entry: KeyVaultEntry<SecKey>) throws(KeyVaultError)
}

struct KeyVaultError: Error {
    let code: Int
}

enum KeyVaultAccessControl: Sendable {
    case none
    case userPresence
}

struct KeyVaultEntry<Key>: Sendable {
    let namespace: String
    let name: String
    let accessControl: KeyVaultAccessControl

    var tag: Data { Data((namespace + "." + name).utf8) }
}

extension KeyVaultEntry {

    init<Other>(_ entry: KeyVaultEntry<Other>) {
        self.namespace = entry.namespace
        self.name = entry.name
        self.accessControl = entry.accessControl
    }
}

struct EC256KeyPair {
    let privateKey: SecKey
    let publicKey: SecKey

    fileprivate init?(privateKey: SecKey) {
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            return nil
        }

        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}

protocol KeyVaultManaged {
    static var keyVaultEntry: KeyVaultEntry<Self> { get }

    init(_ keyPair: EC256KeyPair)
}

extension KeyVault {

    func getOrCreate<Key: KeyVaultManaged>(_ type: Key.Type = Key.self) throws(KeyVaultError) -> Key {
        let convertedEntry = KeyVaultEntry<SecKey>(Key.keyVaultEntry)
        if let existingKey = try get(convertedEntry) {
            return Key(EC256KeyPair(privateKey: existingKey)!) // Expected to never fail in this context.
        } else {
            let newKey = try create(convertedEntry)
            return Key(EC256KeyPair(privateKey: newKey)!) // Expected to never fail in this context.
        }
    }

    func get<Key: KeyVaultManaged>(_ type: Key.Type = Key.self) throws(KeyVaultError) -> Key? {
        let convertedEntry = KeyVaultEntry<SecKey>(Key.keyVaultEntry)
        guard let existingKey = try get(convertedEntry) else {
            return nil
        }
        return Key(EC256KeyPair(privateKey: existingKey)!) // Expected to never fail in this context.
    }

    func delete<Key: KeyVaultManaged>(_ type: Key.Type = Key.self) throws(KeyVaultError) {
        let convertedEntry = KeyVaultEntry<SecKey>(Key.keyVaultEntry)
        try delete(convertedEntry)
    }
}

struct StandardKeyVault {

    /// Generate a NIST P-256 elliptic curve key pair.
    /// Protected by Secure Enclave and stored securely in the keychain.
    /// - Parameter tag: A tag used to identify the key pair. The tag should be unique per key pair.
    /// - Returns: The private key of the newly generated key pair.
    private func createKey(
        withTag tag: Data,
        andAccessControl keyAccessControl: KeyVaultAccessControl
    ) throws(KeyVaultError) -> SecKey {
#if targetEnvironment(simulator)
        // Simulators do not have SecureEnclave.
#else
        guard SecureEnclave.isAvailable else {
            throw CryptographicKeyStorageError.secureEnclaveUnavailable
        }
#endif

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
            throw KeyVaultError(code: CFErrorGetCode(error!.takeUnretainedValue()))
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
            throw KeyVaultError(code: CFErrorGetCode(error!.takeUnretainedValue()))
        }

        return privateKey
    }

    /// Get the private key of a NIST P-256 elliptic curve key pair.
    /// - Parameter tag: The tag that identifies the key pair this private key is part of.
    /// - Returns:The private key of the key pair identified with the given tag.
    private func getKey(withTag tag: Data) throws(KeyVaultError) -> SecKey? {
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
                throw KeyVaultError(code: Int(status))
            }
        }

        // This force cast will always success if status == errSecSuccess
        let privateKey = item as! SecKey

        return privateKey
    }

    /// Delete a previously generated NIST P-256 elliptic curve key pair.
    /// - Parameter tag: The tag that identifies the key pair.
    private func deleteKey(withTag tag: Data) throws(KeyVaultError) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeyVaultError(code: Int(status))
        }
    }
}

extension StandardKeyVault: KeyVault {

    func get(_ entry: KeyVaultEntry<SecKey>) throws(KeyVaultError) -> SecKey? {
        try getKey(withTag: entry.tag)
    }

    func create(_ entry: KeyVaultEntry<SecKey>) throws(KeyVaultError) -> SecKey {
        try createKey(withTag: entry.tag, andAccessControl: entry.accessControl)
    }

    func delete(_ entry: KeyVaultEntry<SecKey>) throws(KeyVaultError) {
        try deleteKey(withTag: entry.tag)
    }
}
