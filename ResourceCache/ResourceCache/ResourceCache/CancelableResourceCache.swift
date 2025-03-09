//
//  CancelableResourceCache.swift
//  ResourceCache
//
//  Created by Thomas Smedmann on 09/03/2025.
//

import Foundation

/// A concurrent and thread safe resource cache that spawns an unstructured Task (via ``PendingOperation``) to fetch a resource when the resource is first requested.
/// All Tasks requesting the resource will be suspended, and a Continuation will be created and stored for each Task (via ``PendingOperation``).
/// Continuations and Tasks will then be resumed once the unstructured resource fetching Task has finished fetching the resource.
/// If a resource requesting Task is canceled while suspended and waiting for the unstructured resource fetching Task,
/// it will be resumed with a partially or unfinished result (empty resource in our case).
final actor CancelableResourceCache {
    private let urlSession: URLSession

    private var pendingOperation: PendingOperation<Data?>?

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: - Private

    private func fetchResource() async throws -> Data? {
        let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/132.png")!
        let request = URLRequest(url: url)

        do {
            let (data, _) = try await urlSession.data(for: request)

            return data
        } catch {
            // Ignoring proper Error handling for simplicity.
            print("Failed to fetch resource:", error)
            return nil
        }
    }

    // MARK: - Public

    var resource: Data? {
        get async {
            let pendingOperation = self.pendingOperation ?? PendingOperation(fetchResource)

            self.pendingOperation = pendingOperation

            return try? await pendingOperation.value()
        }
    }

    var freshResource: Data? {
        get async {
            if pendingOperation?.isCompleted ?? false {
                pendingOperation = nil
            }

            return await resource
        }
    }
}
