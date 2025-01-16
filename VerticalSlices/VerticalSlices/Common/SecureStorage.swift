//
//  SecureStorage.swift
//  VerticalSlices
//
//  Created by Thomas Asheim Smedmann on 21/10/2024.
//

import Foundation
import OSLog

// MARK: Logger extensions

public extension Logger {
    static let secureStorage = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "SecureStorage"
    )
}

// MARK: SecureStorage

public struct SecurelyStorableIdentifier: Sendable, Codable {
    public var namespace: String
    public var key: String

    public init(namespace: String, key: String) {
        self.namespace = namespace
        self.key = key
    }
}

/// Protocol representing something (unique/one of a kind) that should be managed by ``SecureStorage``.
public protocol UniqueSecurelyManaged {
    static var identifier: SecurelyStorableIdentifier { get }

    static func new() -> Self
    static func from(data: Data) throws -> Self
    func toData() throws -> Data
}

internal extension UniqueSecurelyManaged where Self: RawRepresentable<String> {
    static func from(data: Data) throws -> Self {
        guard
            let rawValue = String(data: data, encoding: .utf8),
            let value = Self(rawValue: rawValue)
        else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Data corrupted")
            throw DecodingError.dataCorrupted(context)
        }

        return value
    }

    func toData() throws -> Data {
        Data(rawValue.utf8)
    }
}

internal extension UniqueSecurelyManaged where Self: Codable {
    static func from(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }

    func toData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}

/// Protocol representing something (unique/one of a kind) that can be stored in ``SecureStorage``.
public protocol UniqueSecurelyStorable {
    static var identifier: SecurelyStorableIdentifier { get }

    static func from(data: Data) throws -> Self
    func toData() throws -> Data
}

internal extension UniqueSecurelyStorable where Self: RawRepresentable<String> {
    static func from(data: Data) throws -> Self {
        guard
            let rawValue = String(data: data, encoding: .utf8),
            let value = Self(rawValue: rawValue)
        else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Data corrupted")
            throw DecodingError.dataCorrupted(context)
        }

        return value
    }

    func toData() throws -> Data {
        Data(rawValue.utf8)
    }
}

internal extension UniqueSecurelyStorable where Self: Codable {
    static func from(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }

    func toData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}

/// Protocol representing something that can be stored in ``SecureStorage``.
public protocol SecurelyStorable {
    var identifier: SecurelyStorableIdentifier? { get set }

    static func from(data: Data, with identifier: SecurelyStorableIdentifier) throws -> Self?
    func toData() throws -> Data
}

internal extension SecurelyStorable where Self: Codable {
    static func from(data: Data, with identifier: SecurelyStorableIdentifier) throws -> Self? {
        let decoder = JSONDecoder()
        var value = try decoder.decode(Self.self, from: data)
        value.identifier = identifier
        return value
    }

    func toData() throws -> Data {
        let encoder = JSONEncoder()
        var value = self
        value.identifier = nil
        return try encoder.encode(value)
    }
}

// MARK: SecureStorage

/// An enumeration describing errors that might occur while interacting with ``SecureStorage``.
public enum SecureStorageError: Error {
    case missingIdentifier
    case failedToPersist
    case failedToDelete
    case encodingError(any Error)
    case decodingError(any Error)
    case unexpectedError(Int)
}

/// Protocol representing I/O operations around storing simple data securely (typically in the Keychain).
public protocol SecureStorage: Sendable, AnyObject {
    func getOrCreate<Value: UniqueSecurelyManaged>() throws(SecureStorageError) -> Value
    func get<Value: UniqueSecurelyStorable>() throws(SecureStorageError) -> Value?
    func set<Value: UniqueSecurelyStorable>(_ value: Value) throws(SecureStorageError)
    func delete<Value: UniqueSecurelyStorable>(_: Value.Type) throws(SecureStorageError)
    func get<Value: SecurelyStorable>(_ identifier: SecurelyStorableIdentifier) throws(SecureStorageError) -> Value?
    func set<Value: SecurelyStorable>(_ value: Value) throws(SecureStorageError)
    func delete(_ identifier: SecurelyStorableIdentifier) throws(SecureStorageError)
}

// MARK: TestSecureStorage

public final class TestSecureStorage: @unchecked Sendable, SecureStorage {
    private var storage: [String: Data] = [:]

    public init() {}

    public func getOrCreate<Value: UniqueSecurelyManaged>() throws(SecureStorageError) -> Value {
        Logger.secureStorage.warning("You are using \(String(describing: Self.self))")

        if let data = storage[Value.identifier.key + Value.identifier.namespace] {
            do {
                return try Value.from(data: data)
            } catch {
                throw .decodingError(error)
            }
        } else {
            let value = Value.new()

            do {
                storage[Value.identifier.key + Value.identifier.namespace] = try value.toData()
            } catch {
                throw .encodingError(error)
            }

            return value
        }
    }

    public func get<Value: UniqueSecurelyStorable>() throws(SecureStorageError) -> Value? {
        Logger.secureStorage.warning("You are using \(String(describing: Self.self))")

        guard let data = storage[Value.identifier.key + Value.identifier.namespace] else {
            return nil
        }

        do {
            return try Value.from(data: data)
        } catch {
            throw .decodingError(error)
        }
    }

    public func set<Value: UniqueSecurelyStorable>(_ value: Value) throws(SecureStorageError) {
        Logger.secureStorage.warning("You are using \(String(describing: Self.self))")

        do {
            storage[Value.identifier.key + Value.identifier.namespace] = try value.toData()
        } catch {
            throw .encodingError(error)
        }
    }

    public func delete<Value: UniqueSecurelyStorable>(_: Value.Type) throws(SecureStorageError) {
        Logger.secureStorage.warning("You are using \(String(describing: Self.self))")

        storage[Value.identifier.key + Value.identifier.namespace] = nil
    }

    public func get<Value: SecurelyStorable>(_ identifier: SecurelyStorableIdentifier) throws(SecureStorageError) -> Value? {
        Logger.secureStorage.warning("You are using \(String(describing: Self.self))")

        guard let data = storage[identifier.key + identifier.namespace] else {
            return nil
        }

        do {
            return try Value.from(data: data, with: identifier)
        } catch {
            throw .decodingError(error)
        }
    }

    public func set<Value: SecurelyStorable>(_ value: Value) throws(SecureStorageError) {
        Logger.secureStorage.warning("You are using \(String(describing: Self.self))")

        guard let identifier = value.identifier else {
            throw .missingIdentifier
        }

        do {
            storage[identifier.key + identifier.namespace] = try value.toData()
        } catch {
            throw .encodingError(error)
        }
    }

    public func delete(_ identifier: SecurelyStorableIdentifier) throws(SecureStorageError) {
        Logger.secureStorage.warning("You are using \(String(describing: Self.self))")

        storage[identifier.key + identifier.namespace] = nil
    }
}

// MARK: KeychainSecureStorage

public final class KeychainSecureStorage {
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    public init() {}

    /// Make a Keychain search query based on the given `key` under the given `namespace`.
    private func makeSearchQuery(for key: String, under namespace: String) -> CFDictionary {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecAttrAccount: Data(key.utf8)
        ] as [CFString : Any] as CFDictionary
    }

    /// Make a Keychain copy query based on the given `key` under the given `namespace`.
    private func makeCopyQuery(for key: String, under namespace: String) -> CFDictionary {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecAttrAccount: Data(key.utf8),
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ] as [CFString : Any] as CFDictionary
    }

    /// Make a Keychain add query to add `data` for the given `key` under the given `namespace`.
    /// ``kSecAttrAccessible`` = ``kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`` is necessary to make sure the keychain item is no accessible until after first device unlock (e.g first unlock after device restart),
    /// and will never leave this device (e.g restoring from backup on new device will not include this item).
    private func makeAddQuery(for key: String, under namespace: String, adding data: Data) -> CFDictionary {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecAttrAccount: Data(key.utf8),
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData: data
        ] as [CFString : Any] as CFDictionary
    }

    private func data(for key: String, under namespace: String) throws(SecureStorageError) -> Data? {
        let copyQuery = makeCopyQuery(for: key, under: namespace)

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
                throw SecureStorageError.unexpectedError(Int(status))
        }
    }

    private func set(_ data: Data, for key: String, under namespace: String) throws(SecureStorageError) {
        let searchQuery = makeSearchQuery(for: key, under: namespace)

        let attributes = [
            kSecValueData: data
        ] as CFDictionary

        var status = SecItemUpdate(searchQuery, attributes)

        if status == errSecItemNotFound {
            let addQuery = makeAddQuery(for: key, under: namespace, adding: data)

            status = SecItemAdd(addQuery, nil)
        }

        guard status == errSecSuccess else {
            throw SecureStorageError.failedToPersist
        }
    }

    private func delete(for key: String, under namespace: String) throws(SecureStorageError) {
        let searchQuery = makeSearchQuery(for: key, under: namespace)

        let status = SecItemDelete(searchQuery)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.failedToDelete
        }
    }

    private func deleteAll(under namespace: String) throws(SecureStorageError) {
        let allItemsQuery = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: namespace,
            kSecMatchLimit: kSecMatchLimitAll
        ] as [CFString : Any] as CFDictionary

        let status = SecItemDelete(allItemsQuery)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.failedToDelete
        }
    }

    private func keys(under namespace: String) throws(SecureStorageError) -> [String] {
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
                throw SecureStorageError.unexpectedError(Int(status))
        }
    }
}

extension KeychainSecureStorage: SecureStorage {
    public func getOrCreate<Value: UniqueSecurelyManaged>() throws(SecureStorageError) -> Value {
        Logger.secureStorage.warning("You are using \(String(describing: Self.self))")

        if let data = try data(for: Value.identifier.key, under: Value.identifier.namespace) {
            do {
                return try Value.from(data: data)
            } catch {
                throw .decodingError(error)
            }
        } else {
            let value = Value.new()

            let data: Data
            do {
                data = try value.toData()
            } catch {
                throw .encodingError(error)
            }

            try set(data, for: Value.identifier.key, under: Value.identifier.namespace)

            return value
        }
    }

    public func get<Value: UniqueSecurelyStorable>() throws(SecureStorageError) -> Value? {
        guard let data = try data(for: Value.identifier.key, under: Value.identifier.namespace) else {
            return nil
        }

        do {
            return try Value.from(data: data)
        } catch {
            throw .decodingError(error)
        }
    }

    public func set<Value: UniqueSecurelyStorable>(_ value: Value) throws(SecureStorageError) {
        let data: Data
        do {
            data = try value.toData()
        } catch {
            throw .encodingError(error)
        }

        try set(data, for: Value.identifier.key, under: Value.identifier.namespace)
    }

    public func delete<Value: UniqueSecurelyStorable>(_: Value.Type) throws(SecureStorageError) {
        try delete(for: Value.identifier.key, under: Value.identifier.namespace)
    }

    public func get<Value: SecurelyStorable>(_ identifier: SecurelyStorableIdentifier) throws(SecureStorageError) -> Value? {
        guard let data = try data(for: identifier.key, under: identifier.namespace) else {
            return nil
        }

        do {
            return try Value.from(data: data, with: identifier)
        } catch {
            throw .decodingError(error)
        }
    }

    public func set<Value: SecurelyStorable>(_ value: Value) throws(SecureStorageError) {
        guard let identifier = value.identifier else {
            throw .missingIdentifier
        }

        let data: Data
        do {
            data = try value.toData()
        } catch {
            throw .encodingError(error)
        }

        try set(data, for: identifier.key, under: identifier.namespace)
    }

    public func delete(_ identifier: SecurelyStorableIdentifier) throws(SecureStorageError) {
        try delete(for: identifier.key, under: identifier.namespace)
    }
}

// MARK: Exposing SecureStorage to SwiftUI

import SwiftUI

public extension EnvironmentValues {
    @Entry var secureStorage: SecureStorage = TestSecureStorage()
}

public extension View {
    func secureStorage(_ secureStorage: SecureStorage) -> some View {
        environment(\.secureStorage, secureStorage)
    }
}

/// A custom convenience property wrapper adhering to DynamicProperty.
@MainActor @propertyWrapper public struct SecurelyStored<Value: UniqueSecurelyStorable>: DynamicProperty {
    @Environment(\.secureStorage) private var secureStorage

    public init() {}

    public var wrappedValue: Value? {
        get { try? secureStorage.get() }
        set {
            if let newValue {
                try? secureStorage.set(newValue)
            } else {
                try? secureStorage.delete(Value.self)
            }
        }
    }
}
