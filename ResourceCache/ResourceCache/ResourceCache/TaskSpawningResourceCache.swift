//
//  TaskSpawningResourceCache.swift
//  ResourceCache
//
//  Created by Thomas Asheim Smedmann on 24/02/2024.
//

import Foundation

/// A concurrent and thread safe resource cache that spawns an unstructured Task to fetch a resource when the resource is first requested.
/// All Tasks requesting the resource will wait on the completion of the spawned unstructured resource fetching Task.
final actor TaskSpawningResourceCache {
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

            let task = Task<Data?, Never> { [weak self] in
                guard let self else {
                    return nil
                }

                return await self.fetchResource()
            }

            resourceFetchingTask = task

            let resource = await task.value

            cachedResource = resource
            resourceFetchingTask = nil

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
