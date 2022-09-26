//
//  KeychainSecureStorage.swift
//  KeychainStorage
//
//  Created by Thomas Asheim Smedmann on 26/09/2022.
//

import Foundation

final class KeychainSecureStorage {

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    private func searchQuery(for key: String) throws -> CFDictionary {
        guard let tag = key.data(using: .utf8) else {
            throw SecureStorageError.invalidKey
        }

        return [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag
        ] as CFDictionary
    }

    private func copyQuery(for key: String) throws -> CFDictionary {
        guard let tag = key.data(using: .utf8) else {
            throw SecureStorageError.invalidKey
        }

        return [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ] as CFDictionary
    }

    private func addQuery(for key: String, data: Data) throws -> CFDictionary {
        guard let tag = key.data(using: .utf8) else {
            throw SecureStorageError.invalidKey
        }

        return [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag,
            kSecValueData: data
        ] as CFDictionary
    }
}

// MARK: SecureStorage

extension KeychainSecureStorage: SecureStorage {
    func fetchObject<T>(for key: String) throws -> T where T: AnyObject {
        let copyQuery = try copyQuery(for: key)

        var item: CFTypeRef?

        let status = SecItemCopyMatching(copyQuery, &item)

        guard
            status == errSecSuccess,
            let data = item as? Data
        else {
            throw SecureStorageError.notFound(
                description: SecCopyErrorMessageString(status, nil) as? String
            )
        }

        guard let object = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T else {
            throw SecureStorageError.typeMismatch
        }

        return object
    }

    func persistObject<T>(_ object: T, for key: String) throws where T: AnyObject {
        let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)

        let searchQuery = try searchQuery(for: key)

        let attributes = [
            kSecValueData: data
        ] as CFDictionary

        var status = SecItemUpdate(searchQuery, attributes)

        if status == errSecItemNotFound {
            let addQuery = try addQuery(for: key, data: data)

            status = SecItemAdd(addQuery, nil)
        }

        guard status == errSecSuccess else {
            throw SecureStorageError.failedToPersist(
                description: SecCopyErrorMessageString(status, nil) as? String
            )
        }
    }

    func fetchValue<T>(for key: String) throws -> T where T : Decodable {
        let copyQuery = try copyQuery(for: key)

        var item: CFTypeRef?

        let status = SecItemCopyMatching(copyQuery, &item)

        guard
            status == errSecSuccess,
            let data = item as? Data
        else {
            throw SecureStorageError.notFound(
                description: SecCopyErrorMessageString(status, nil) as? String
            )
        }

        return try jsonDecoder.decode(T.self, from: data)
    }

    func persistValue<T>(_ value: T, for key: String) throws where T : Encodable {
        let data = try jsonEncoder.encode(value)

        let searchQuery = try searchQuery(for: key)

        let attributes = [
            kSecValueData: data
        ] as CFDictionary

        var status = SecItemUpdate(searchQuery, attributes)

        if status == errSecItemNotFound {
            let addQuery = try addQuery(for: key, data: data)

            status = SecItemAdd(addQuery, nil)
        }

        guard status == errSecSuccess else {
            throw SecureStorageError.failedToPersist(
                description: SecCopyErrorMessageString(status, nil) as? String
            )
        }
    }

    func fetchString(for key: String) throws -> String {
        let copyQuery = try copyQuery(for: key)

        var item: CFTypeRef?

        let status = SecItemCopyMatching(copyQuery, &item)

        guard
            status == errSecSuccess,
            let data = item as? Data
        else {
            throw SecureStorageError.notFound(
                description: SecCopyErrorMessageString(status, nil) as? String
            )
        }

        guard let value = String(data: data, encoding: .utf8) else {
            throw SecureStorageError.typeMismatch
        }

        return value
    }

    func persistString(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw SecureStorageError.invalidValue
        }

        let searchQuery = try searchQuery(for: key)

        let attributes = [
            kSecValueData: data
        ] as CFDictionary

        var status = SecItemUpdate(searchQuery, attributes)

        if status == errSecItemNotFound {
            let addQuery = try addQuery(for: key, data: data)

            status = SecItemAdd(addQuery, nil)
        }

        guard status == errSecSuccess else {
            throw SecureStorageError.failedToPersist(
                description: SecCopyErrorMessageString(status, nil) as? String
            )
        }
    }

    func delete(for key: String) throws {
        let searchQuery = try searchQuery(for: key)

        let status = SecItemDelete(searchQuery)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.failedToDelete(
                description: SecCopyErrorMessageString(status, nil) as? String
            )
        }
    }
}
