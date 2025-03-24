//
//  DefaultsStorage.swift
//  SignalingStorage
//
//  Created by Thomas Smedmann on 23/03/2025.
//

import Foundation

/// Representing the absolute bare minimum abstraction around `UserDefaults`.
struct DefaultsStorage: @unchecked Sendable {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func set<Value: Encodable>(_ value: Value, for key: String, under namespace: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        let key = namespace.isEmpty ? key : "\(namespace).\(key)"
        userDefaults.set(data, forKey: key)
    }

    func value<Value: Decodable>(for key: String, under namespace: String) throws -> Value? {
        let key = namespace.isEmpty ? key : "\(namespace).\(key)"
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(Value.self, from: data)
    }

    func delete(for key: String, under namespace: String) throws {
        let key = namespace.isEmpty ? key : "\(namespace).\(key)"
        userDefaults.removeObject(forKey: key)
    }
}
