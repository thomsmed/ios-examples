//
//  HomeView.swift
//  VerticalSlices
//
//  Created by Thomas Asheim Smedmann on 21/10/2024.
//

import SwiftUI
import HTTP
import GRDB

struct Username: RawRepresentable {
    var rawValue: String
}

extension Username: DefaultsStorable {
    static let namespace: String = "app"
    static let key: String = "username"
}

struct Password: RawRepresentable {
    var rawValue: String
}

struct Login {
    let username: Username
    let accessToken: AccessToken
}

extension Login {
    static func authenticate(
        withUsername username: Username,
        andPassword password: Password
    ) -> HTTP.Endpoint<Login> {
        struct RequestBody: Encodable {
            let username: String
            let password: String
        }

        let requestBody = RequestBody(
            username: username.rawValue,
            password: password.rawValue
        )
        let url = URL(string: "https://ios.example.authenticate")!

        return HTTP.Endpoint(
            url: url,
            method: .post,
            payload: (try? .json(from: requestBody)) ?? .empty(),
            parser: HTTP.ResponseParser(mimeType: .json) { response in
                guard HTTP.Status.successful.contains(response.statusCode) else {
                    throw HTTP.UnexpectedResponse(response)
                }

                struct ResponseBody: Decodable {
                    let accessToken: String
                }

                let responseBody = try response.parsed(as: ResponseBody.self, using: .json())
                let accessToken = AccessToken(rawValue: responseBody.accessToken)

                return Login(username: username, accessToken: accessToken)
            }
        )
    }
}

struct Note {
    var id: String?
    let title: String
    let detail: String
}

extension Note: DatabaseEntity {
    func save(using dbClient: DatabaseClient) async throws {
        try await dbClient.write { db in
            if try Note.filter(id: self.id).fetchOne(db) != nil {
                try self.update(db)
            } else {
                try self.insert(db)
            }
        }
    }

    static func fetchAll(using dbClient: DatabaseClient) async throws -> [Note] {
        try await dbClient.read { db in
            try Note.fetchAll(db)
        }
    }
}

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
