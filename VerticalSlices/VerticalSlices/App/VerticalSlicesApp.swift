//
//  VerticalSlicesApp.swift
//  VerticalSlices
//
//  Created by Thomas Asheim Smedmann on 21/10/2024.
//

import SwiftUI
import HTTP

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
                .defaultsStorage(StandardUserDefaultsStorage())
                .secureStorage(KeychainSecureStorage())
                .cryptographicKeyStorage(SecureCryptographicKeyStorage())
                .httpClient(HTTP.Client())
                .databaseClient(GRDBDatabaseClient(
                    connectionString: Self.documentDirectoryPath
                        .appending(path: "VerticalSlices.sqlite3")
                        .absoluteString
                ))
                .featureToggles(FeatureToggles(syncEngine: RemoteFeatureToggleSyncEngine()))
        }
    }
}
