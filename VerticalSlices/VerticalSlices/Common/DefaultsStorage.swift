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
        subsystem: "ios.example.VerticalSlices",
        category: "DefaultsStorage"
    )
}

// MARK: DefaultsStorable

public protocol DefaultsStorageGetter {
    func integer<Storable: DefaultsStorable>(for storable: Storable.Type) -> Int?
    func double<Storable: DefaultsStorable>(for storable: Storable.Type) -> Double?
    func string<Storable: DefaultsStorable>(for storable: Storable.Type) -> String?
    func value<Storable: DefaultsStorable, Value: Codable>(for storable: Storable.Type) -> Value?
}

public protocol DefaultsStorageSetter {
    func set<Storable: DefaultsStorable>(_ integer: Int, for storable: Storable.Type)
    func set<Storable: DefaultsStorable>(_ double: Double, for storable: Storable.Type)
    func set<Storable: DefaultsStorable>(_ string: String, for storable: Storable.Type)
    func set<Storable: DefaultsStorable, Value: Codable>(_ value: Value, for storable: Storable.Type)
}

/// Protocol representing something that can be stored in ``DefaultsStorage``.
public protocol DefaultsStorable {
    static var namespace: String { get }
    static var key: String { get }

    static func load(using getter: some DefaultsStorageGetter) -> Self?
    func save(using setter: some DefaultsStorageSetter)
}

internal extension DefaultsStorable {
    static var combinedKey: String { Self.namespace + "." + Self.key }
}

internal extension DefaultsStorable where Self: RawRepresentable<Int> {
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

internal extension DefaultsStorable where Self: RawRepresentable<Double> {
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

internal extension DefaultsStorable where Self: RawRepresentable<String> {
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

internal extension DefaultsStorable where Self: Codable {
    static func load(using getter: some DefaultsStorageGetter) -> Self? {
        getter.value(for: Self.self)
    }

    func save(using setter: some DefaultsStorageSetter) {
        setter.set(self, for: Self.self)
    }
}

// MARK: DefaultsStorage

/// Protocol representing I/O operations around storing simple Defaults data (typically in the UserDefaults.standard).
public protocol DefaultsStorage: Sendable {
    func get<Value: DefaultsStorable>() -> Value?
    func set<Value: DefaultsStorable>(_ value: Value)
    func delete<Value: DefaultsStorable>(_: Value.Type)
}

// MARK: TestDefaultsStorage

public final class TestDefaultsStorage: @unchecked Sendable, DefaultsStorageGetter, DefaultsStorageSetter {
    private var storage: [String: Any] = [:]

    public init() {}

    public func integer<Storable: DefaultsStorable>(for storable: Storable.Type) -> Int? {
        storage[Storable.combinedKey] as? Int
    }

    public func set<Storable: DefaultsStorable>(_ integer: Int, for storable: Storable.Type) {
        storage[Storable.combinedKey] = integer
    }

    public func double<Storable: DefaultsStorable>(for storable: Storable.Type) -> Double? {
        storage[Storable.combinedKey] as? Double
    }

    public func set<Storable: DefaultsStorable>(_ double: Double, for storable: Storable.Type) {
        storage[Storable.combinedKey] = double
    }

    public func string<Storable: DefaultsStorable>(for storable: Storable.Type) -> String? {
        storage[Storable.combinedKey] as? String
    }

    public func set<Storable: DefaultsStorable>(_ string: String, for storable: Storable.Type) {
        storage[Storable.combinedKey] = string
    }

    public func value<Storable: DefaultsStorable, Value: Codable>(for storable: Storable.Type) -> Value? {
        storage[Storable.combinedKey] as? Value
    }

    public func set<Storable: DefaultsStorable, Value: Codable>(_ value: Value, for storable: Storable.Type) {
        storage[Storable.combinedKey] = value
    }
}

extension TestDefaultsStorage: DefaultsStorage {
    public func get<Value: DefaultsStorable>() -> Value? {
        Logger.defaultsStorage.warning("You are using \(String(describing: Self.self))")

        return Value.load(using: self)
    }

    public func set<Value: DefaultsStorable>(_ value: Value) {
        Logger.defaultsStorage.warning("You are using \(String(describing: Self.self))")

        value.save(using: self)
    }

    public func delete<Value: DefaultsStorable>(_: Value.Type) {
        Logger.defaultsStorage.warning("You are using \(String(describing: Self.self))")

        storage[Value.combinedKey] = nil
    }
}

// MARK: UserDefaultsStorage

/// A general storage for stuff stored in the UserDefaults.
public final class StandardUserDefaultsStorage: DefaultsStorageGetter, DefaultsStorageSetter {

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    public func integer<Storable: DefaultsStorable>(for storable: Storable.Type) -> Int? {
        UserDefaults.standard.integer(forKey: Storable.combinedKey)
    }

    public func set<Storable: DefaultsStorable>(_ integer: Int, for storable: Storable.Type) {
        UserDefaults.standard.set(integer, forKey: Storable.combinedKey)

    }

    public func double<Storable: DefaultsStorable>(for storable: Storable.Type) -> Double? {
        UserDefaults.standard.double(forKey: Storable.combinedKey)
    }

    public func set<Storable: DefaultsStorable>(_ double: Double, for storable: Storable.Type) {
        UserDefaults.standard.set(double, forKey: Storable.combinedKey)
    }

    public func string<Storable: DefaultsStorable>(for storable: Storable.Type) -> String? {
        UserDefaults.standard.string(forKey: Storable.combinedKey)
    }

    public func set<Storable: DefaultsStorable>(_ string: String, for storable: Storable.Type) {
        UserDefaults.standard.set(string, forKey: Storable.combinedKey)
    }

    public func value<Storable: DefaultsStorable, Value: Codable>(for storable: Storable.Type) -> Value? {
        guard let data = UserDefaults.standard.data(forKey: Storable.combinedKey) else {
            return nil
        }
        return try? jsonDecoder.decode(Value.self, from: data)
    }

    public func set<Storable: DefaultsStorable, Value: Codable>(_ value: Value, for storable: Storable.Type) {
        guard let data = try? jsonEncoder.encode(value) else {
            return
        }
        UserDefaults.standard.set(data, forKey: Storable.combinedKey)
    }
}

extension StandardUserDefaultsStorage: DefaultsStorage {
    public func get<Value: DefaultsStorable>() -> Value? {
        Value.load(using: self)
    }

    public func set<Value: DefaultsStorable>(_ value: Value) {
        value.save(using: self)
    }

    public func delete<Value: DefaultsStorable>(_: Value.Type) {
        UserDefaults.standard.removeObject(forKey: Value.combinedKey)
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
@MainActor @propertyWrapper public struct DefaultsStored<Value: DefaultsStorable>: DynamicProperty {
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
