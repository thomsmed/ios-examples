//
//  Models.swift
//  VerticalSlices
//
//  Created by Thomas Smedmann on 16/01/2025.
//

import Foundation
import HTTP
import GRDB

struct Username: RawRepresentable {
    var rawValue: String
}

extension Username: UniqueDefaultsStorable {
    static let identifier = DefaultsStorableIdentifier(namespace: "app", key: "username")
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
