//
//  DefaultsRepository.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 09/07/2022.
//

import Foundation

enum Defaults {
    enum key: String {
        case onboardingCompleted
    }
}

protocol DefaultsRepository: AnyObject {
    func get<T: Codable>(_ key: Defaults.key) -> T?
    func set<T: Codable>(_ object: T, for key: Defaults.key)
    func getBool(forKey key: Defaults.key)
}
