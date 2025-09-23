//
//  ContentView.swift
//  EntityComponentSystem
//
//  Created by Thomas Smedmann on 22/09/2025.
//

import Security
import SwiftUI

struct ContentView: View {
    @State private var httpSession: HTTPSession = URLSession.shared
    @State private var defaults: Defaults = UserDefaults.standard
    @State private var secureDefaults: SecureDefaults = StandardSecureDefaults()
    @State private var keyVault: KeyVault = StandardKeyVault()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            do {
                // Using the HTTP system
                let userId = UUID()
                let endpoint = User.with(id: userId)
                let user =
                    (try? await httpSession.call(endpoint))
                    ?? User(id: userId, name: "User", birthday: .now)
                let _ = try? await httpSession.call(user.profileImage)

                // Using the key-value store system
                try defaults.store(user)
                let _ = defaults.retrieve(.firstAppLaunch)
                if let user = try defaults.retrieve(User.self) {
                    defaults.store(user.birthday, as: .userBirthDate)
                }

                // Using the secure key-value store system
                try secureDefaults.store(user)
                let _ = try secureDefaults.retrieve(.userId)
                if let user = try secureDefaults.retrieve(User.self) {
                    try secureDefaults.store(user.id, as: .userId)
                }

                // Using the managed cryptographic keys system
                let _ = try keyVault.getOrCreate(DeviceKey.self)
                let _ = try keyVault.getOrCreate(UserKey.self)
                if (try keyVault.get(UserKey.self)) != nil {
                    try keyVault.delete(UserKey.self)
                }

                printUserDefaultsKeys()
                printKeychainItems()
            } catch {
                print("Error:", error)
            }
        }
    }
}

// MARK: Utils

func printUserDefaultsKeys() {
    print("Keys in standard UserDefaults:")
    UserDefaults.standard
        .dictionaryRepresentation()
        .keys
        .forEach { key in
            print(key)
        }
}

enum SecClass: String, CaseIterable {
    // Available keychain item classes:
    // https://developer.apple.com/documentation/security/keychain_services/keychain_items/item_class_keys_and_values#1678477

    case genericPassword
    case internetPassword
    case certificate
    case key
    case identity

    var cfString: CFString {
        switch self {
        case .genericPassword:
            return kSecClassGenericPassword
        case .internetPassword:
            return kSecClassInternetPassword
        case .certificate:
            return kSecClassCertificate
        case .key:
            return kSecClassKey
        case .identity:
            return kSecClassIdentity
        }
    }
}

func printKeychainItems() {
    SecClass.allCases.forEach { secClass in
        let searchQuery =
            [
                kSecClass: secClass.cfString,
                kSecMatchLimit: kSecMatchLimitAll,
                kSecReturnAttributes: true,
            ] as CFDictionary

        var result: CFTypeRef?
        let status = SecItemCopyMatching(searchQuery, &result)

        switch status {
        case errSecItemNotFound:
            print("No items of class \(secClass.rawValue) in keychain")
        case errSecSuccess:
            let items = result as? [[CFString: Any]] ?? []
            print("\(items.count) items of class \(secClass.rawValue):")
            items.forEach { item in
                print("Access group:", item[kSecAttrAccessGroup] ?? "")
                print("Service:", item[kSecAttrService] ?? "")
                print("Account:", item[kSecAttrAccount] ?? "")
                print("Description:", item[kSecAttrDescription] ?? "")
                if let data = item[kSecAttrApplicationTag] as? Data {
                    print(
                        "Application tag:",
                        String(data: data, encoding: .utf8) ?? ""
                    )
                } else {
                    print(
                        "Application tag:",
                        item[kSecAttrApplicationTag] ?? ""
                    )
                }
                print("Key type:", item[kSecAttrKeyType] ?? "")
                print("Available attributes:", item.keys)
            }
        default:
            print("Something went wrong")
        }
    }
}

#Preview {
    ContentView()
}
