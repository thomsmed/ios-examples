//
//  ContinuationCreatingResourceCache.swift
//  ResourceCache
//
//  Created by Thomas Asheim Smedmann on 24/02/2024.
//

import Foundation

/// A resource cache that will make the first resource requesting Task fetch the resource asynchronously while being suspended.
/// All subsequent Tasks requesting the resource will be suspended, and a Continuation will be created and stored for each Task.
/// Continuations and Tasks will then be resumed once the initial Task has finished fetching the resource.
final actor ContinuationCreatingResourceCache {
    private enum CachedResourceState {
        case none
        case fetching
        case value(Data?)
    }

    private let urlSession: URLSession

    private let waitingContinuationsLocker = WaitingContinuationsLocker()
    private var cachedResourceState: CachedResourceState = .none

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
            switch cachedResourceState {
                case .none:
                    cachedResourceState = .fetching

                    let resource = await fetchResource()

                    cachedResourceState = .value(resource)

                    while let (_, waitingContinuation) = waitingContinuationsLocker.popFirst() {
                        // Resume suspended Continuations/Tasks by returning the fetched resource.
                        waitingContinuation.resume(returning: resource)
                    }

                    return resource

                case .fetching:
                    let id = UUID()

                    return await withCheckedContinuation { continuation in
                        waitingContinuationsLocker.set(continuation, forId: id)
                    }

                case let .value(resource):
                    return resource
            }
        }
    }

    var freshResource: Data? {
        get async {
            cachedResourceState = .none

            return await resource
        }
    }
}
