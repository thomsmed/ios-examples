//
//  DefaultsRepository.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

enum Defaults {
    enum Codable: String {
        case favoritePaymentMethod
    }

    enum Boolean: String {
        case onboardingCompleted
    }

    enum Text: String {
        case voucher
    }

    enum Date: String {
        case firstAppLaunch
    }
}

protocol DefaultsRepository: AnyObject {
    func get<T: Codable>(_ key: Defaults.Codable) -> T?
    func set<T: Codable>(_ object: T, for key: Defaults.Codable)
    func bool(for key: Defaults.Boolean) -> Bool
    func set(_ value: Bool, for key: Defaults.Boolean)
    func string(for key: Defaults.Text) -> String?
    func set(_ value: String, for key: Defaults.Text)
    func date(for key: Defaults.Date) -> Date?
    func set(_ value: Date, for key: Defaults.Date)
}
