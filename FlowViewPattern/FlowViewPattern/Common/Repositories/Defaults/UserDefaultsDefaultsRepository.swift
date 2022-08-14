//
//  UserDefaultsDefaultsRepository.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class UserDefaultsDefaultsRepository {

    private let userDefaults = UserDefaults.standard

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
}

extension UserDefaultsDefaultsRepository: DefaultsRepository {

    func get<T>(_ key: Defaults.Codable) -> T? where T : Codable {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
            return nil
        }

        return try? jsonDecoder.decode(T.self, from: data)
    }

    func set<T>(_ object: T, for key: Defaults.Codable) where T : Codable {
        guard let data = try? jsonEncoder.encode(object) else {
            return
        }

        userDefaults.set(data, forKey: key.rawValue)
    }

    func bool(for key: Defaults.Boolean) -> Bool {
        userDefaults.bool(forKey: key.rawValue)
    }

    func set(_ value: Bool, for key: Defaults.Boolean) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    func string(for key: Defaults.Text) -> String? {
        userDefaults.string(forKey: key.rawValue)
    }

    func set(_ value: String, for key: Defaults.Text) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    func date(for key: Defaults.Date) -> Date? {
        let timeInterval = userDefaults.double(forKey: key.rawValue)

        guard timeInterval > 0 else {
            return nil
        }

        return Date(timeIntervalSince1970: timeInterval)
    }

    func set(_ value: Date, for key: Defaults.Date) {
        userDefaults.set(value.timeIntervalSince1970, forKey: key.rawValue)
    }
}
