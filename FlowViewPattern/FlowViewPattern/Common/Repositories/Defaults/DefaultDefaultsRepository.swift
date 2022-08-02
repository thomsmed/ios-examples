//
//  DefaultDefaultsRepository.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class DefaultDefaultsRepository {

    private let userDefaults = UserDefaults.standard

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
}

extension DefaultDefaultsRepository: DefaultsRepository {

    func get<T>(_ key: Defaults.Key) -> T? where T : Codable {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
            return nil
        }

        return try? jsonDecoder.decode(T.self, from: data)
    }

    func set<T>(_ object: T, for key: Defaults.Key) where T : Codable {
        guard let data = try? jsonEncoder.encode(object) else {
            return
        }

        userDefaults.set(data, forKey: key.rawValue)
    }

    func getBool(for key: Defaults.Key) -> Bool {
        userDefaults.bool(forKey: key.rawValue)
    }

    func set(_ value: Bool, for key: Defaults.Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    func getString(for key: Defaults.Key) -> String? {
        userDefaults.string(forKey: key.rawValue)
    }

    func set(_ value: String, for key: Defaults.Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }
}
