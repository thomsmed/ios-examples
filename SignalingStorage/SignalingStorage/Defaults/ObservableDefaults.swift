//
//  ObservableDefaults.swift
//  SignalingStorage
//
//  Created by Thomas Smedmann on 23/03/2025.
//

import Foundation

/// An abstraction around `UserDefaults` that implement `ObservableObject`.
/// Will publish change events whenever any value changes.
final class ObservableDefaults: Sendable, ObservableObject {
    protocol Storage: Sendable {
        func set<Value: Encodable>(_ value: Value, for key: String, under namespace: String) throws
        func value<Value: Decodable>(for key: String, under namespace: String) throws -> Value?
        func delete(for key: String, under namespace: String) throws
    }

    static let shared = ObservableDefaults(storage: DefaultsStorage())

    private let storage: any Storage

    public init(storage: any Storage) {
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
}

// MARK: DefaultsStorage+ObservableDefaults.Storage

extension DefaultsStorage: ObservableDefaults.Storage {}

// MARK: ObservedDefaulted

import SwiftUI

@MainActor @propertyWrapper struct ObservedDefaulted<Value: Codable>: DynamicProperty {
    private let key: String
    private let namespace: String

    @ObservedObject private var defaults: ObservableDefaults

    init(
        key: String,
        namespace: String,
        defaults: ObservableDefaults = .shared
    ) {
        self.key = key
        self.namespace = namespace
        self.defaults = defaults
    }

    var wrappedValue: Value? {
        get {
            try? defaults.value(for: key, under: namespace)
        }
        nonmutating set {
            if let newValue {
                try? defaults.set(newValue, for: key, under: namespace)
            } else {
                try? defaults.delete(for: key, under: namespace)
            }
        }
    }

    var projectedValue: Binding<Value?> {
        Binding(get: { [defaults, key, namespace] in
            try? defaults.value(for: key, under: namespace)
        }, set: { [defaults, key, namespace] newValue in
            if let newValue {
                try? defaults.set(newValue, for: key, under: namespace)
            } else {
                try? defaults.delete(for: key, under: namespace)
            }
        })
    }
}
