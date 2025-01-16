//
//  Models.swift
//  VerticalSlices
//
//  Created by Thomas Smedmann on 10/11/2024.
//

import Foundation

struct DeviceStickyIdentifier: RawRepresentable {
    var rawValue: String
}

extension DeviceStickyIdentifier: UniqueSecurelyManaged {
    static let identifier = SecurelyStorableIdentifier(namespace: "app", key: "sticky-identifier")

    static func new() -> DeviceStickyIdentifier {
        Self(rawValue: UUID().uuidString)
    }
}

struct AppInstallation: Codable {
    let date: Date
    let identifier: String
}

extension AppInstallation: UniqueSecurelyManaged {
    static let identifier = SecurelyStorableIdentifier(namespace: "app", key: "installation")

    static func new() -> AppInstallation {
        Self(date: .now, identifier: UUID().uuidString)
    }
}

struct DeviceKey {
    let privateKey: SecKey
    let publicKey: SecKey
}

extension DeviceKey: UniqueManagedCryptographicKey {
    static let accessControl: ManagedCryptographicKeyAccessControl = .none
    static let identifier = ManagedCryptographicKeyIdentifier(namespace: "app", tag: "device-key")

    init(_ keyPair: EC256KeyPair) {
        self.privateKey = keyPair.privateKey
        self.publicKey = keyPair.publicKey
    }
}

struct SigningKey {
    let identifier: ManagedCryptographicKeyIdentifier

    let privateKey: SecKey
    let publicKey: SecKey
}

extension SigningKey: ManagedCryptographicKey {
    static let accessControl: ManagedCryptographicKeyAccessControl = .userPresence

    init(_ keyPair: EC256KeyPair, identifier: ManagedCryptographicKeyIdentifier) {
        self.privateKey = keyPair.privateKey
        self.publicKey = keyPair.publicKey
        self.identifier = identifier
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

struct Enrollment {
    struct Qualification {
        let phoneNumber: String
        let emailAddress: String

        private init(phoneNumber: String, emailAddress: String) {
            self.phoneNumber = phoneNumber
            self.emailAddress = emailAddress
        }

        func qualify(phoneNumber: String, emailAddress: String) -> Qualification {
            return Qualification(phoneNumber: phoneNumber, emailAddress: emailAddress)
        }
    }

    struct Identification {
        let name: String
        let imageData: Data

        private init(name: String, imageData: Data) {
            self.name = name
            self.imageData = imageData
        }

        func identify(basedOn qualification: Qualification) -> Identification {
            // ...
            return Identification(name: "Name", imageData: Data())
        }
    }

    struct Personalization {
        func personalize(basedOn identification: Identification) -> Activation {
            // ...
            let identifier = "identifier"
            // ...
            return Activation(
                identifier: identifier,
                name: identification.name,
                imageData: identification.imageData
            )
        }
    }
}

struct Activation {
    let identifier: String
    let name: String
    let imageData: Data
}
