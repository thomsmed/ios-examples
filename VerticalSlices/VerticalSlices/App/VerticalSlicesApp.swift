//
//  VerticalSlicesApp.swift
//  VerticalSlices
//
//  Created by Thomas Asheim Smedmann on 21/10/2024.
//

import SwiftUI
import AppDependencies
import HTTP

extension AppDependencies {
    var documentDirectoryPath: Registration<URL> {
        Registration(self) { _ in
            guard
                let documentDirectoryPath = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                ).first
            else {
                fatalError("Could not find path to Document directory")
            }
            return documentDirectoryPath
        }
    }

    var defaultsStorage: Registration<DefaultsStorage> {
        Registration(self) { _ in
            StandardUserDefaultsStorage()
        }
    }

    var secureStorage: Registration<SecureStorage> {
        Registration(self) { _ in
            KeychainSecureStorage()
        }
    }

    var cryptographicKeyStorage: Registration<CryptographicKeyStorage> {
        Registration(self) { _ in
            SecureCryptographicKeyStorage()
        }
    }

    var httpClient: Registration<HTTP.Client> {
        Registration(self) { _ in
            HTTP.Client()
        }
    }

    var databaseClient: Registration<DatabaseClient> {
        Registration(self) {
            GRDBDatabaseClient(
                connectionString: $0.documentDirectoryPath()
                    .appending(path: "VerticalSlices.sqlite3")
                    .absoluteString
            )
        }
    }

    var featureToggles: Registration<FeatureToggles> {
        Registration(self) { _ in
            FeatureToggles(syncEngine: RemoteFeatureToggleSyncEngine())
        }
    }
}

@main
struct VerticalSlicesApp: App {
    private static let documentDirectoryPath: URL = {
        guard
            let documentDirectoryPath = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
        else {
            fatalError("Could not find path to Document directory")
        }
        return documentDirectoryPath
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
