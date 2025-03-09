//
//  ResourceCache.swift
//  ResourceCache
//
//  Created by Thomas Smedmann on 09/03/2025.
//

import Foundation

/// A concurrent and thread safe resource cache that spawns an unstructured Task to fetch a resource when the resource is first requested.
/// All Tasks requesting the resource will wait on the completion of the spawned unstructured resource fetching Task.
/// Task cancelation is not handled.
final actor ResourceCache {
    private let urlSession: URLSession

    private var cachedResource: Data?
    private var resourceFetchingTask: Task<Data?, Never>?

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: - Private

    private func fetchResource() async -> Data? {
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
            if let cachedResource {
                return cachedResource
            }

            if let resourceFetchingTask {
                return await resourceFetchingTask.value
            }

            let task: Task<Data?, Never> = .detached(
                operation: fetchResource
            )

            resourceFetchingTask = task
            defer { resourceFetchingTask = nil }

            let resource = await task.value

            cachedResource = resource

            return resource
        }
    }

    var freshResource: Data? {
        get async {
            cachedResource = nil

            return await resource
        }
    }
}
