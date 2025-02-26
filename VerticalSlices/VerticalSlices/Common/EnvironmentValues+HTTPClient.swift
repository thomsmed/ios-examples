//
//  EnvironmentValues+HTTPClient.swift
//  VerticalSlices
//
//  Created by Thomas Asheim Smedmann on 25/10/2024.
//

import SwiftUI
import OSLog
import HTTP

// MARK: Logger extensions

public extension Logger {
    static let networking = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "Networking"
    )
}

// MARK: MockSession

public final class MockSession: HTTP.Session, @unchecked Sendable {
    public let decoder = JSONDecoder()
    public let encoder = JSONEncoder()

    public var dataAndResponseForRequest: (_ request: URLRequest) async -> (Data, HTTPURLResponse) = { _ in (Data(), HTTPURLResponse()) }

    public func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        Logger.networking.warning("You are using \(String(describing: Self.self))")

        return await dataAndResponseForRequest(request)
    }
}
