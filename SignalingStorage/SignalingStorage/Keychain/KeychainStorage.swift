//
//  KeychainStorage.swift
//  SignalingStorage
//
//  Created by Thomas Smedmann on 23/03/2025.
//

import Foundation

/// An enumeration describing errors that might occur while interacting with ``KeychainStorage``.
enum KeychainStorageError: Error {
    case typeMismatch
    case failedToPersist
    case failedToDelete
    case unexpectedError(Int)
}

/// Representing the absolute bare minimum abstraction around the Keychain.
struct KeychainStorage: Sendable {
    /// Make a Keychain search query based on the given `key`.
    private func makeSearchQuery(
        for key: String,
        under namespace: String
    ) throws -> CFDictionary {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecAttrAccount: Data(key.utf8)
        ] as [CFString : Any] as CFDictionary
    }

    /// Make a Keychain copy query based on the given `key`.
    private func makeCopyQuery(
        for key: String,
        under namespace: String
    ) throws -> CFDictionary {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecAttrAccount: Data(key.utf8),
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ] as [CFString : Any] as CFDictionary
    }

    /// Make a Keychain add query based on the given `key` and `data`.
    /// ``kSecAttrAccessible`` = ``kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`` is necessary to make sure the keychain item is no accessible until after first device unlock (e.g first unlock after device restart),
    /// and will never leave this device (e.g restoring from backup on new device will not include this item).
    private func makeAddQuery(
        for key: String,
        under namespace: String,
        adding data: Data
    ) throws -> CFDictionary {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecAttrAccount: Data(key.utf8),
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData: data
        ] as [CFString : Any] as CFDictionary
    }
}

extension KeychainStorage {
    func set<Value: Encodable>(_ value: Value, for key: String, under namespace: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)

        let searchQuery = try makeSearchQuery(for: key, under: namespace)

        let attributes = [
            kSecValueData: data
        ] as CFDictionary

        var status = SecItemUpdate(searchQuery, attributes)

        if status == errSecItemNotFound {
            let addQuery = try makeAddQuery(for: key, under: namespace, adding: data)

            status = SecItemAdd(addQuery, nil)
        }

        guard status == errSecSuccess else {
            throw KeychainStorageError.failedToPersist
        }
    }

    func value<Value: Decodable>(for key: String, under namespace: String) throws -> Value? {
        let copyQuery = try makeCopyQuery(for: key, under: namespace)

        var item: CFTypeRef?

        let status = SecItemCopyMatching(copyQuery, &item)

        switch status {
        case errSecSuccess:
            guard let data = item as? Data else {
                throw KeychainStorageError.typeMismatch
            }

            let decoder = JSONDecoder()
            return try decoder.decode(Value.self, from: data)

        case errSecItemNotFound:
            return nil

        default:
            throw KeychainStorageError.unexpectedError(Int(status))
        }
    }

    func delete(for key: String, under namespace: String) throws {
        let searchQuery = try makeSearchQuery(for: key, under: namespace)

        let status = SecItemDelete(searchQuery)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainStorageError.failedToDelete
        }
    }

    func deleteAll(under namespace: String) throws {
        let allItemsQuery = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecMatchLimit: kSecMatchLimitAll
        ] as [CFString : Any] as CFDictionary

        let status = SecItemDelete(allItemsQuery)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainStorageError.failedToDelete
        }
    }

    func keys(under namespace: String) throws -> [String] {
        let attributesForAllItemsQuery = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecMatchLimit: kSecMatchLimitAll,
            kSecReturnAttributes: true
        ] as [CFString : Any] as CFDictionary

        var items: CFTypeRef?

        let status = SecItemCopyMatching(
            attributesForAllItemsQuery, &items
        )

        switch status {
        case errSecSuccess:
            guard let attributeDictionaries = items as? [[CFString: Any]] else {
                throw KeychainStorageError.typeMismatch
            }

            return attributeDictionaries.compactMap { attributes in
                attributes[kSecAttrAccount] as? String
            }

        case errSecItemNotFound:
            return []

        default:
            throw KeychainStorageError.unexpectedError(Int(status))
        }
    }
}
