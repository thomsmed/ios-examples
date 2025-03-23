//
//  ObservableKeychain.swift
//  SignalingStorage
//
//  Created by Thomas Smedmann on 23/03/2025.
//

import Foundation

/// An abstraction around the `Keychain` that implement `ObservableObject`.
/// Will publish change events whenever any value changes.
final class ObservableKeychain: Sendable, ObservableObject {
    protocol Storage: Sendable {
        func set<Value: Encodable>(_ value: Value, for key: String, under namespace: String) throws
        func value<Value: Decodable>(for key: String, under namespace: String) throws -> Value?
        func delete(for key: String, under namespace: String) throws
        func deleteAll(under namespace: String) throws
        func keys(under namespace: String) throws -> [String]
    }

    static let shared = ObservableKeychain(storage: KeychainStorage())

    private let storage: any Storage

    init(storage: any Storage) {
        self.storage = storage
    }

    func set<Value: Encodable>(_ value: Value, for key: String, under namespace: String) throws {
        try storage.set(value, for: key, under: namespace)

        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    func value<Value: Decodable>(for key: String, under namespace: String) throws -> Value? {
        try storage.value(for: key, under: namespace)
    }

    func delete(for key: String, under namespace: String) throws {
        try storage.delete(for: key, under: namespace)

        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    func deleteAll(under namespace: String) throws {
        try storage.deleteAll(under: namespace)

        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    func keys(under namespace: String) throws -> [String] {
        try storage.keys(under: namespace)
    }
}

// MARK: KeychainStorage+ObservableKeychain.Storage

extension KeychainStorage: ObservableKeychain.Storage {}

// MARK: ObservedKeychained

import SwiftUI

@MainActor @propertyWrapper struct ObservedKeychained<Value: Codable>: DynamicProperty {
    private let key: String
    private let namespace: String

    @ObservedObject private var keychain: ObservableKeychain

    init(
        key: String,
        namespace: String,
        keychain: ObservableKeychain = .shared
    ) {
        self.key = key
        self.namespace = namespace
        self.keychain = keychain
    }

    var wrappedValue: Value? {
        get {
            try? keychain.value(for: key, under: namespace)
        }
        nonmutating set {
            if let newValue {
                try? keychain.set(newValue, for: key, under: namespace)
            } else {
                try? keychain.delete(for: key, under: namespace)
            }
        }
    }

    var projectedValue: Binding<Value?> {
        Binding(get: { [keychain, key, namespace] in
            try? keychain.value(for: key, under: namespace)
        }, set: { [keychain, key, namespace] newValue in
            if let newValue {
                try? keychain.set(newValue, for: key, under: namespace)
            } else {
                try? keychain.delete(for: key, under: namespace)
            }
        })
    }
}
