//
//  HomeView.swift
//  VerticalSlices
//
//  Created by Thomas Asheim Smedmann on 21/10/2024.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.defaultsStorage) private var defaultsStorage
    @Environment(\.secureStorage) private var secureStorage
    @Environment(\.cryptographicKeyStorage) private var cryptographicKeyStorage
    @Environment(\.httpClient) private var httpClient
    @Environment(\.databaseClient) private var databaseClient

    @FeatureToggle(.secretFeature) private var secretFeatureEnabled: Bool

    @DefaultsStored private var storedUsername: Username?
    @SecurelyStored private var accessToken: AccessToken?
    @ProtectedCryptographicKey private var deviceKey: DeviceKey?

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var notes: [Note] = []

    var body: some View {
        List {
            Section("Notes") {
                ForEach(notes) { note in
                    HStack {
                        Text(note.title)
                        Text(note.detail)
                            .font(.caption)
                    }
                }
            }

            Section("Login") {
                TextField("Username", text: $username)
                    .autocorrectionDisabled()
                    .padding()

                SecureField("Password", text: $password)
                    .padding()
                    .onSubmit {
                        Task {
                            let username = Username(rawValue: username)
                            let password = Password(rawValue: password)

                            let login = try await httpClient.call(Login.authenticate(
                                withUsername: username, andPassword: password
                            ))

                            defaultsStorage.set(login.username)
                            try secureStorage.set(login.accessToken)

                            let notes = try await Note.fetchAll(using: databaseClient)

                            if notes.isEmpty {
                                let note = Note(title: "Initial Note", detail: "This is just an initial Note.")
                                try await note.save(using: databaseClient)
                            }
                        }
                    }
            }

            if secretFeatureEnabled {
                Section("Secret Feature") {
                    Text("Welcome to the Secret Feature!")
                }
            }
        }
        .textFieldStyle(.roundedBorder)
        .onAppear {
            do {
                // Ensure Device Key presence
                let _: DeviceKey = try cryptographicKeyStorage.getOrCreate()
            } catch {
                assertionFailure("Why did this happen?")
            }
        }
    }
}

#Preview {
    HomeView()
}
