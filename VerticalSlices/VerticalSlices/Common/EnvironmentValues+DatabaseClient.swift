//
//  EnvironmentValues+Database.swift
//  VerticalSlices
//
//  Created by Thomas Smedmann on 03/11/2024.
//

import SwiftUI
import OSLog
import GRDB

// MARK: Logger extensions

public extension Logger {
    static let database = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "Database"
    )
}

// MARK: DatabaseClient

public protocol DatabaseEntity: Codable, Identifiable, FetchableRecord, PersistableRecord {}

/// Protocol representing I/O operations around storing data in a database. In reality this is just a thing wrapper around ``GRDB``,
/// to make it easier to differentiate between test database(s) and non-test database(s).
public protocol DatabaseClient: Sendable {
    func read<T>(_ value: @Sendable @escaping (GRDB.Database) throws -> T) async throws -> T
    func write<T>(_ updates: @Sendable @escaping (GRDB.Database) throws -> T) async throws -> T
}

// MARK: TestDatabaseClient

public final class TestDatabaseClient: DatabaseClient {
    internal let dbQueue: DatabaseQueue

    init(named name: String) {
        do {
            dbQueue = try DatabaseQueue(named: name)
        } catch {
            fatalError("Could not instantiate in-memory database name \"\(name)\"")
        }
    }

    public func read<T>(_ value: @Sendable @escaping (GRDB.Database) throws -> T) async throws -> T {
        Logger.database.warning("You are using \(String(describing: Self.self))")

        return try await dbQueue.read(value)
    }

    public func write<T>(_ updates: @Sendable @escaping (GRDB.Database) throws -> T) async throws -> T {
        Logger.database.warning("You are using \(String(describing: Self.self))")

        return try await dbQueue.write(updates)
    }
}

// MARK: GRDBDatabaseClient

public final class GRDBDatabaseClient {
    internal let dbQueue: DatabaseQueue

    init(connectionString: String) {
        do {
            dbQueue = try DatabaseQueue(path: connectionString)
            try migrate(dbQueue)
        } catch {
            fatalError("Could not connect to SQLite database at \(connectionString)")
        }
    }

    private func migrate(_ dbQueue: DatabaseQueue) throws {
        let migrator = DatabaseMigrator()

        // ...

        try migrator.migrate(dbQueue)
    }
}

extension GRDBDatabaseClient: DatabaseClient {
    public func read<T>(_ value: @Sendable @escaping (GRDB.Database) throws -> T) async throws -> T {
        try await dbQueue.read(value)
    }

    public func write<T>(_ updates: @Sendable @escaping (GRDB.Database) throws -> T) async throws -> T {
        try await dbQueue.write(updates)
    }
}
