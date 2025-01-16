//
//  DefaultsStorage.swift
//  VerticalSlices
//
//  Created by Thomas Asheim Smedmann on 21/10/2024.
//

import Foundation
import OSLog

// MARK: Logger extensions

public extension Logger {
    static let defaultsStorage = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "DefaultsStorage"
    )
}

// MARK: DefaultsStorable

public struct DefaultsStorableIdentifier: Sendable, Codable {
    public var namespace: String
    public var key: String

    public init(namespace: String, key: String) {
        self.namespace = namespace
        self.key = key
    }

    internal var combinedKey: String { namespace + "." + key }
}

public protocol DefaultsStorageGetter {
    func integer<Storable: UniqueDefaultsStorable>(for storable: Storable.Type) -> Int?
    func double<Storable: UniqueDefaultsStorable>(for storable: Storable.Type) -> Double?
    func string<Storable: UniqueDefaultsStorable>(for storable: Storable.Type) -> String?
    func value<Storable: UniqueDefaultsStorable, Value: Codable>(for storable: Storable.Type) -> Value?
}

public protocol DefaultsStorageSetter {
    func set<Storable: UniqueDefaultsStorable>(_ integer: Int, for storable: Storable.Type)
    func set<Storable: UniqueDefaultsStorable>(_ double: Double, for storable: Storable.Type)
    func set<Storable: UniqueDefaultsStorable>(_ string: String, for storable: Storable.Type)
    func set<Storable: UniqueDefaultsStorable, Value: Codable>(_ value: Value, for storable: Storable.Type)
}

/// Protocol representing something (unique/one of a kind) that can be stored in ``DefaultsStorage``.
public protocol UniqueDefaultsStorable {
    static var identifier: DefaultsStorableIdentifier { get }

    static func load(using getter: some DefaultsStorageGetter) -> Self?
    func save(using setter: some DefaultsStorageSetter)
}

internal extension UniqueDefaultsStorable where Self: RawRepresentable<Int> {
    static func load(using getter: some DefaultsStorageGetter) -> Self? {
        guard let rawValue = getter.integer(for: Self.self) else {
            return nil
        }
        return Self(rawValue: rawValue)
    }

    func save(using setter: some DefaultsStorageSetter) {
        setter.set(rawValue, for: Self.self)
    }
}

internal extension UniqueDefaultsStorable where Self: RawRepresentable<Double> {
    static func load(using getter: some DefaultsStorageGetter) -> Self? {
        guard let rawValue = getter.double(for: Self.self) else {
            return nil
        }
        return Self(rawValue: rawValue)
    }

    func save(using setter: some DefaultsStorageSetter) {
        setter.set(rawValue, for: Self.self)
    }
}

internal extension UniqueDefaultsStorable where Self: RawRepresentable<String> {
    static func load(using getter: some DefaultsStorageGetter) -> Self? {
        guard let rawValue = getter.string(for: Self.self) else {
            return nil
        }
        return Self(rawValue: rawValue)
    }

    func save(using setter: some DefaultsStorageSetter) {
        setter.set(rawValue, for: Self.self)
    }
}

internal extension UniqueDefaultsStorable where Self: Codable {
    static func load(using getter: some DefaultsStorageGetter) -> Self? {
        getter.value(for: Self.self)
    }

    func save(using setter: some DefaultsStorageSetter) {
        setter.set(self, for: Self.self)
    }
}

/// Protocol representing something that can be stored in ``DefaultsStorage``.
public protocol DefaultsStorable: Codable {
    var identifier: DefaultsStorableIdentifier? { get set }
}

// MARK: DefaultsStorage

public struct MissingDefaultsStorableIdentifier: Error {}

/// Protocol representing I/O operations around storing simple Defaults data (typically in the UserDefaults.standard).
public protocol DefaultsStorage: Sendable {
    func get<Value: UniqueDefaultsStorable>() -> Value?
    func set<Value: UniqueDefaultsStorable>(_ value: Value)
    func delete<Value: UniqueDefaultsStorable>(_: Value.Type)
    func get<Value: DefaultsStorable>(_ identifier: DefaultsStorableIdentifier) -> Value?
    func set<Value: DefaultsStorable>(_ value: Value) throws(MissingDefaultsStorableIdentifier)
    func delete(_ identifier: DefaultsStorableIdentifier)
}

// MARK: TestDefaultsStorage

public final class TestDefaultsStorage: @unchecked Sendable, DefaultsStorageGetter, DefaultsStorageSetter {
    private var storage: [String: Any] = [:]

    public init() {}

    public func integer<Storable: UniqueDefaultsStorable>(for storable: Storable.Type) -> Int? {
        storage[Storable.identifier.combinedKey] as? Int
    }

    public func set<Storable: UniqueDefaultsStorable>(_ integer: Int, for storable: Storable.Type) {
        storage[Storable.identifier.combinedKey] = integer
    }

    public func double<Storable: UniqueDefaultsStorable>(for storable: Storable.Type) -> Double? {
        storage[Storable.identifier.combinedKey] as? Double
    }

    public func set<Storable: UniqueDefaultsStorable>(_ double: Double, for storable: Storable.Type) {
        storage[Storable.identifier.combinedKey] = double
    }

    public func string<Storable: UniqueDefaultsStorable>(for storable: Storable.Type) -> String? {
        storage[Storable.identifier.combinedKey] as? String
    }

    public func set<Storable: UniqueDefaultsStorable>(_ string: String, for storable: Storable.Type) {
        storage[Storable.identifier.combinedKey] = string
    }

    public func value<Storable: UniqueDefaultsStorable, Value: Codable>(for storable: Storable.Type) -> Value? {
        storage[Storable.identifier.combinedKey] as? Value
    }

    public func set<Storable: UniqueDefaultsStorable, Value: Codable>(_ value: Value, for storable: Storable.Type) {
        storage[Storable.identifier.combinedKey] = value
    }
}

extension TestDefaultsStorage: DefaultsStorage {
    public func get<Value: UniqueDefaultsStorable>() -> Value? {
        Logger.defaultsStorage.warning("You are using \(String(describing: Self.self))")

        return Value.load(using: self)
    }

    public func set<Value: UniqueDefaultsStorable>(_ value: Value) {
        Logger.defaultsStorage.warning("You are using \(String(describing: Self.self))")

        value.save(using: self)
    }

    public func delete<Value: UniqueDefaultsStorable>(_: Value.Type) {
        Logger.defaultsStorage.warning("You are using \(String(describing: Self.self))")

        storage[Value.identifier.combinedKey] = nil
    }

    public func get<Value: DefaultsStorable>(_ identifier: DefaultsStorableIdentifier) -> Value? {
        Logger.defaultsStorage.warning("You are using \(String(describing: Self.self))")

        return storage[identifier.combinedKey] as? Value
    }

    public func set<Value: DefaultsStorable>(_ value: Value) throws(MissingDefaultsStorableIdentifier) {
        Logger.defaultsStorage.warning("You are using \(String(describing: Self.self))")

        guard let identifier = value.identifier else {
            throw MissingDefaultsStorableIdentifier()
        }

        storage[identifier.combinedKey] = value
    }

    public func delete(_ identifier: DefaultsStorableIdentifier) {
        Logger.defaultsStorage.warning("You are using \(String(describing: Self.self))")

        storage[identifier.combinedKey] = nil
    }
}

// MARK: UserDefaultsStorage

/// A general storage for stuff stored in the UserDefaults.
public final class StandardUserDefaultsStorage: DefaultsStorageGetter, DefaultsStorageSetter {

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    public func integer<Storable: UniqueDefaultsStorable>(for storable: Storable.Type) -> Int? {
        UserDefaults.standard.integer(forKey: Storable.identifier.combinedKey)
    }

    public func set<Storable: UniqueDefaultsStorable>(_ integer: Int, for storable: Storable.Type) {
        UserDefaults.standard.set(integer, forKey: Storable.identifier.combinedKey)

    }

    public func double<Storable: UniqueDefaultsStorable>(for storable: Storable.Type) -> Double? {
        UserDefaults.standard.double(forKey: Storable.identifier.combinedKey)
    }

    public func set<Storable: UniqueDefaultsStorable>(_ double: Double, for storable: Storable.Type) {
        UserDefaults.standard.set(double, forKey: Storable.identifier.combinedKey)
    }

    public func string<Storable: UniqueDefaultsStorable>(for storable: Storable.Type) -> String? {
        UserDefaults.standard.string(forKey: Storable.identifier.combinedKey)
    }

    public func set<Storable: UniqueDefaultsStorable>(_ string: String, for storable: Storable.Type) {
        UserDefaults.standard.set(string, forKey: Storable.identifier.combinedKey)
    }

    public func value<Storable: UniqueDefaultsStorable, Value: Codable>(for storable: Storable.Type) -> Value? {
        guard let data = UserDefaults.standard.data(forKey: Storable.identifier.combinedKey) else {
            return nil
        }
        return try? jsonDecoder.decode(Value.self, from: data)
    }

    public func set<Storable: UniqueDefaultsStorable, Value: Codable>(_ value: Value, for storable: Storable.Type) {
        guard let data = try? jsonEncoder.encode(value) else {
            return
        }
        UserDefaults.standard.set(data, forKey: Storable.identifier.combinedKey)
    }
}

extension StandardUserDefaultsStorage: DefaultsStorage {
    public func get<Value: UniqueDefaultsStorable>() -> Value? {
        Value.load(using: self)
    }

    public func set<Value: UniqueDefaultsStorable>(_ value: Value) {
        value.save(using: self)
    }

    public func delete<Value: UniqueDefaultsStorable>(_: Value.Type) {
        UserDefaults.standard.removeObject(forKey: Value.identifier.combinedKey)
    }

    public func get<Value: DefaultsStorable>(_ identifier: DefaultsStorableIdentifier) -> Value? {
        guard let data = UserDefaults.standard.data(forKey: identifier.combinedKey) else {
            return nil
        }

        guard var value = try? jsonDecoder.decode(Value.self, from: data) else {
            return nil
        }

        value.identifier = identifier

        return value
    }

    public func set<Value: DefaultsStorable>(_ value: Value) throws(MissingDefaultsStorableIdentifier) {
        guard let identifier = value.identifier else {
            throw MissingDefaultsStorableIdentifier()
        }

        var value = value
        value.identifier = nil

        guard let data = try? jsonEncoder.encode(value) else {
            return
        }

        UserDefaults.standard.set(data, forKey: identifier.combinedKey)
    }

    public func delete(_ identifier: DefaultsStorableIdentifier) {
        UserDefaults.standard.removeObject(forKey: identifier.combinedKey)
    }
}

// MARK: Exposing DefaultsStorage to SwiftUI

import SwiftUI

public extension EnvironmentValues {
    @Entry var defaultsStorage: DefaultsStorage = TestDefaultsStorage()
}

public extension View {
    func defaultsStorage(_ defaultsStorage: DefaultsStorage) -> some View {
        environment(\.defaultsStorage, defaultsStorage)
    }
}

/// A custom convenience property wrapper adhering to DynamicProperty.
@MainActor @propertyWrapper public struct DefaultsStored<Value: UniqueDefaultsStorable>: DynamicProperty {
    @Environment(\.defaultsStorage) private var defaultsStorage

    public init() {}

    public var wrappedValue: Value? {
        get { defaultsStorage.get() }
        set {
            if let newValue {
                defaultsStorage.set(newValue)
            } else {
                defaultsStorage.delete(Value.self)
            }
        }
    }
}
