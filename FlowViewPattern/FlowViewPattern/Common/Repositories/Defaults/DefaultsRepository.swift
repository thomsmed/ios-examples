//
//  DefaultsRepository.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

enum Defaults {
    enum Key: String {
        case onboardingCompleted
    }
}

protocol DefaultsRepository: AnyObject {
    func get<T: Codable>(_ key: Defaults.Key) -> T?
    func set<T: Codable>(_ object: T, for key: Defaults.Key)
    func bool(for key: Defaults.Key) -> Bool
    func set(_ value: Bool, for key: Defaults.Key)
    func string(for key: Defaults.Key) -> String?
    func set(_ value: String, for key: Defaults.Key)
    func date(for key: Defaults.Key) -> Date?
    func set(_ value: Date, for key: Defaults.Key)
}
