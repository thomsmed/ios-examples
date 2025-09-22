//
//  Defaults.swift
//  EntityComponentSystem
//
//  Created by Thomas Smedmann on 22/09/2025.
//

import Foundation

protocol Defaults {
    func store(_ double: Double, as entry: DefaultsEntry<Double>)
    func store(_ string: String, as entry: DefaultsEntry<String>)
    func store<Value>(_ data: Data, as entry: DefaultsEntry<Value>)

    func retrieve(_ entry: DefaultsEntry<Double>) -> Double?
    func retrieve(_ entry: DefaultsEntry<String>) -> String?
    func retrieve<Value>(_ entry: DefaultsEntry<Value>) -> Data?

    func delete<Value>(_ entry: DefaultsEntry<Value>)
}

struct DefaultsEntry<Target>: Sendable {
    let namespace: String
    let name: String

    var key: String { namespace + "." + name }
}

protocol DefaultsStored: Codable {
    static var defaultsEntry: DefaultsEntry<Self> { get }
}

extension Defaults {

    func store(_ date: Date, as entry: DefaultsEntry<Date>) {
        let timeInterval = date.timeIntervalSince1970
        let convertedEntry = DefaultsEntry<Double>(namespace: entry.namespace, name: entry.name)
        self.store(timeInterval, as: convertedEntry)
    }

    func store<Value: Codable>(_ value: Value, as entry: DefaultsEntry<Value>) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        self.store(data, as: entry)
    }

    func store<Value: DefaultsStored>(_ value: Value) throws {
        try store(value, as: Value.defaultsEntry)
    }

    func retrieve(_ entry: DefaultsEntry<Date>) -> Date? {
        let convertedEntry = DefaultsEntry<Double>(namespace: entry.namespace, name: entry.name)
        guard let timeInterval = self.retrieve(convertedEntry) else {
            return nil
        }
        return Date(timeIntervalSince1970: timeInterval)
    }

    func retrieve<Value: Codable>(_ entry: DefaultsEntry<Value>) throws -> Value? {
        guard let data = self.retrieve(entry) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(Value.self, from: data)
    }

    func retrieve<Value: DefaultsStored>(_ type: Value.Type) throws -> Value? {
        try retrieve(Value.defaultsEntry)
    }
}

extension UserDefaults: Defaults {

    func store(_ double: Double, as entry: DefaultsEntry<Double>) {
        self.set(double, forKey: entry.key)
    }

    func store(_ string: String, as entry: DefaultsEntry<String>) {
        self.set(string, forKey: entry.key)
    }

    func store<Value>(_ data: Data, as entry: DefaultsEntry<Value>) {
        self.set(data, forKey: entry.key)
    }

    func retrieve(_ entry: DefaultsEntry<Double>) -> Double? {
        self.double(forKey: entry.key)
    }

    func retrieve(_ entry: DefaultsEntry<String>) -> String? {
        self.string(forKey: entry.key)
    }

    func retrieve<Value>(_ entry: DefaultsEntry<Value>) -> Data? {
        self.data(forKey: entry.key)
    }

    func delete<Value>(_ entry: DefaultsEntry<Value>) {
        self.removeObject(forKey: entry.key)
    }
}
