//
//  SecureDefaults.swift
//  EntityComponentSystem
//
//  Created by Thomas Smedmann on 22/09/2025.
//

import Foundation

protocol SecureDefaults {
    func store(_ double: Double, as entry: SecureDefaultsEntry<Double>) throws
    func store(_ string: String, as entry: SecureDefaultsEntry<String>) throws
    func store<Value>(_ data: Data, as entry: SecureDefaultsEntry<Value>) throws

    func retrieve(_ entry: SecureDefaultsEntry<Double>) throws -> Double?
    func retrieve(_ entry: SecureDefaultsEntry<String>) throws -> String?
    func retrieve<Value>(_ entry: SecureDefaultsEntry<Value>) throws -> Data?

    func delete<Value>(_ entry: SecureDefaultsEntry<Value>) throws
}

struct SecureDefaultsError: Error {
    let code: Int
}

struct SecureDefaultsEntry<Target>: Sendable {
    let namespace: String
    let name: String
}

protocol SecureDefaultsStored: Codable {
    static var secureDefaultsEntry: SecureDefaultsEntry<Self> { get }
}

extension SecureDefaults {

    func store(_ date: Date, as entry: SecureDefaultsEntry<Date>) throws {
        let timeInterval = date.timeIntervalSince1970
        let convertedEntry = SecureDefaultsEntry<Double>(namespace: entry.namespace, name: entry.name)
        try self.store(timeInterval, as: convertedEntry)
    }

    func store<Value: Codable>(_ value: Value, as entry: SecureDefaultsEntry<Value>) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        try self.store(data, as: entry)
    }

    func store<Value: SecureDefaultsStored>(_ value: Value) throws {
        try store(value, as: Value.secureDefaultsEntry)
    }

    func retrieve(_ entry: SecureDefaultsEntry<Date>) throws -> Date? {
        let convertedEntry = SecureDefaultsEntry<Double>(namespace: entry.namespace, name: entry.name)
        guard let timeInterval = try self.retrieve(convertedEntry) else {
            return nil
        }
        return Date(timeIntervalSince1970: timeInterval)
    }

    func retrieve<Value: Codable>(_ entry: SecureDefaultsEntry<Value>) throws -> Value? {
        guard let data = try self.retrieve(entry) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(Value.self, from: data)
    }

    func retrieve<Value: SecureDefaultsStored>(_ type: Value.Type) throws -> Value? {
        try retrieve(Value.secureDefaultsEntry)
    }
}

struct StandardSecureDefaults {

    /// Make a Keychain search query based on the given `name` under the given `namespace`.
    private func makeSearchQuery(for name: String, under namespace: String) -> CFDictionary {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecAttrAccount: name,
        ] as [CFString : Any] as CFDictionary
    }

    /// Make a Keychain copy query based on the given `name` under the given `namespace`.
    private func makeCopyQuery(for name: String, under namespace: String) -> CFDictionary {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecAttrAccount: name,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ] as [CFString : Any] as CFDictionary
    }

    /// Make a Keychain add query to add `data` for the given `name` under the given `namespace`.
    /// ``kSecAttrAccessible`` = ``kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`` is necessary to make sure the keychain item is no accessible until after first device unlock (e.g first unlock after device restart),
    /// and will never leave this device (e.g restoring from backup on new device will not include this item).
    private func makeAddQuery(adding data: Data, for name: String, under namespace: String) -> CFDictionary {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecAttrAccount: name,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData: data
        ] as [CFString : Any] as CFDictionary
    }

    private func data(for name: String, under namespace: String) throws(SecureDefaultsError) -> Data? {
        let copyQuery = makeCopyQuery(for: name, under: namespace)

        var item: CFTypeRef?

        let status = SecItemCopyMatching(copyQuery, &item)

        switch status {
        case errSecSuccess:
            guard let data = item as? Data else {
                return nil
            }

            return data

        case errSecItemNotFound:
            return nil

        default:
            throw SecureDefaultsError(code: Int(status))
        }
    }

    private func set(_ data: Data, for name: String, under namespace: String) throws(SecureDefaultsError) {
        let searchQuery = makeSearchQuery(for: name, under: namespace)

        let attributes = [
            kSecValueData: data
        ] as CFDictionary

        var status = SecItemUpdate(searchQuery, attributes)

        if status == errSecItemNotFound {
            let addQuery = makeAddQuery(adding: data, for: name, under: namespace)

            status = SecItemAdd(addQuery, nil)
        }

        guard status == errSecSuccess else {
            throw SecureDefaultsError(code: Int(status))
        }
    }

    private func delete(for key: String, under namespace: String) throws(SecureDefaultsError) {
        let searchQuery = makeSearchQuery(for: key, under: namespace)

        let status = SecItemDelete(searchQuery)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureDefaultsError(code: Int(status))
        }
    }

    private func deleteAll(under namespace: String) throws(SecureDefaultsError) {
        let allItemsQuery = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecMatchLimit: kSecMatchLimitAll
        ] as [CFString : Any] as CFDictionary

        let status = SecItemDelete(allItemsQuery)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureDefaultsError(code: Int(status))
        }
    }

    private func keys(under namespace: String) throws(SecureDefaultsError) -> [String] {
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
                return []
            }

            return attributeDictionaries.compactMap { attributes in
                attributes[kSecAttrAccount] as? String
            }

        case errSecItemNotFound:
            return []

        default:
            throw SecureDefaultsError(code: Int(status))
        }
    }
}

extension StandardSecureDefaults: SecureDefaults {

    func store(_ double: Double, as entry: SecureDefaultsEntry<Double>) throws {
        let data = withUnsafeBytes(of: double) { Data($0) }
        try self.set(data, for: entry.name, under: entry.namespace)
    }

    func store(_ string: String, as entry: SecureDefaultsEntry<String>) throws {
        let data = Data(string.utf8)
        try self.set(data, for: entry.name, under: entry.namespace)
    }

    func store<Value>(_ data: Data, as entry: SecureDefaultsEntry<Value>) throws {
        try self.set(data, for: entry.name, under: entry.namespace)
    }

    func retrieve(_ entry: SecureDefaultsEntry<Double>) throws -> Double? {
        guard let data = try self.data(for: entry.name, under: entry.namespace) else {
            return nil
        }
        return data.withUnsafeBytes {
            $0.load(as: Double.self)
        }
    }

    func retrieve(_ entry: SecureDefaultsEntry<String>) throws -> String? {
        guard let data = try self.data(for: entry.name, under: entry.namespace) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func retrieve<Value>(_ entry: SecureDefaultsEntry<Value>) throws -> Data? {
        try self.data(for: entry.name, under: entry.namespace)
    }

    func delete<Value>(_ entry: SecureDefaultsEntry<Value>) throws {
        try self.delete(for: entry.name, under: entry.namespace)
    }
}
