//
//  TaskSpawningCancelingResourceCache.swift
//  ResourceCache
//
//  Created by Thomas Asheim Smedmann on 24/02/2024.
//

//
//  TaskSpawningCancelingResourceCache.swift
//

import Foundation

/// A concurrent and thread safe resource cache that spawns an unstructured Task to fetch a resource when the resource is first requested.
/// All Tasks requesting the resource will wait on the completion of the spawned unstructured resource fetching Task.
/// If all resource requesting Tasks are canceled, the resource cache will also cancel the spawned unstructured resource fetching Task.
final actor TaskSpawningCancelingResourceCache {
    private let urlSession: URLSession

    private var cachedResource: Data?
    private var resourceFetchingTask: Task<Data?, Never>?

    private let waitingTasksCount = AtomicCount() // Alternative 1
    // private let waitingTasksCount = LockedCount() // Alternative 2

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
                waitingTasksCount.increment()

                return await withTaskCancellationHandler {
                    await resourceFetchingTask.value
                } onCancel: {
                    waitingTasksCount.decrement()

                    if waitingTasksCount.value > 0 {
                        return
                    }

                    // Cancel the resource fetching Task,
                    // since there are no longer any other Tasks waiting for the result.
                    resourceFetchingTask.cancel()
                }
            } else {
                waitingTasksCount.reset()

                let task = Task<Data?, Never> { [weak self] in
                    guard let self else {
                        return nil
                    }

                    // One could imagine this Task having to fetch and combine multiple resources,
                    // then it might be desirable to check for cancelation before and after each chunk of async work.

                    if Task.isCancelled {
                        return nil
                    }

                    let resource = await self.fetchResource()

                    if Task.isCancelled {
                        return nil
                    }

                    return resource
                }

                resourceFetchingTask = task

                waitingTasksCount.increment()

                return await withTaskCancellationHandler {
                    let resource = await task.value

                    cachedResource = resource
                    resourceFetchingTask = nil

                    return resource
                } onCancel: {
                    waitingTasksCount.decrement()

                    if waitingTasksCount.value > 0 {
                        return
                    }

                    // Cancel the resource fetching Task,
                    // since there are no longer any other Tasks waiting for the result.
                    task.cancel()
                }
            }
        }
    }

    var freshResource: Data? {
        get async {
            cachedResource = nil

            return await resource
        }
    }
}

