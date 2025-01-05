//
//  Models.swift
//  VerticalSlices
//
//  Created by Thomas Smedmann on 10/11/2024.
//

import Foundation

struct DeviceKey {
    let privateKey: SecKey
    let publicKey: SecKey
}

extension DeviceKey: ManagedCryptographicKey {
    static let namespace: String = "app"
    static let tag: String = "device-key"
    static let accessControl: ManagedCryptographicKeyAccessControl = .none

    init(_ keyPair: EC256KeyPair) {
        self.privateKey = keyPair.privateKey
        self.publicKey = keyPair.publicKey
    }
}

struct AccessToken: RawRepresentable {
    var rawValue: String
}

extension AccessToken: UniqueSecurelyStorable {
    static let identifier = SecurelyStorableIdentifier(namespace: "app", key: "access-token")
}

struct Secret: Codable {
    var identifier: SecurelyStorableIdentifier?

    let name: String
    let data: Data
}

extension Secret: SecurelyStorable {}

struct Sticker: Codable {
    var identifier: DefaultsStorableIdentifier?

    let name: String
    let icon: Data
}

extension Sticker: DefaultsStorable {}
