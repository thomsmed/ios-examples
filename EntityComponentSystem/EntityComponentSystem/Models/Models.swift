//
//  Models.swift
//  EntityComponentSystem
//
//  Created by Thomas Smedmann on 22/09/2025.
//

import Foundation

struct User {
    let id: UUID
    let name: String
    let birthday: Date
}

extension User: Decodable {}

/// Component(s) for the managed cryptographic keys system (`KeyVault`).
struct DeviceKey: KeyVaultManaged {
    static let keyVaultEntry = KeyVaultEntry<Self>(namespace: "general", name: "deviceKey", accessControl: .none)

    let keyPair: EC256KeyPair

    init(_ keyPair: EC256KeyPair) {
        self.keyPair = keyPair
    }
}

/// Component(s) for the managed cryptographic keys system (`KeyVault`).
struct UserKey: KeyVaultManaged {
    static let keyVaultEntry = KeyVaultEntry<Self>(namespace: "user", name: "key", accessControl: .userPresence)

    let keyPair: EC256KeyPair

    init(_ keyPair: EC256KeyPair) {
        self.keyPair = keyPair
    }
}

/// Component(s) for the HTTP system (`HTTPSession`).
extension User {

    static func with(id: UUID) -> Endpoint<User> {
        let url = URL(string: "https://example.ios/users")!
            .appending(path: id.uuidString)
        return Endpoint(url: url, payload: .empty, parser: .json)
    }

    var profileImage: Endpoint<Data> {
        let url = URL(string: "https://example.ios/users")!
            .appending(path: id.uuidString)
            .appending(path: "image")
        return Endpoint(url: url, payload: .empty, parser: .raw)
    }
}

/// Component(s) for the key-value store system (`Defaults`).
extension DefaultsEntry {

    static var firstAppLaunch: DefaultsEntry<Date> {
        DefaultsEntry<Date>(namespace: "general", name: "firstAppLaunch")
    }

    static var userBirthDate: DefaultsEntry<Date> {
        DefaultsEntry<Date>(namespace: "user", name: "birthdate")
    }
}

/// Component(s) for the key-value store system (`Defaults`).
extension User: DefaultsStored {

    static let defaultsEntry = DefaultsEntry<User>(namespace: "general", name: "user")
}

/// Component(s) for the secure key-value store system (`SecureDefaults`).
extension SecureDefaultsEntry {

    static var userId: SecureDefaultsEntry<UUID> {
        SecureDefaultsEntry<UUID>(namespace: "user", name: "id")
    }
}

/// Component(s) for the secure key-value store system (`SecureDefaults`).
extension User: SecureDefaultsStored {

    static let secureDefaultsEntry = SecureDefaultsEntry<User>(namespace: "general", name: "user")
}
