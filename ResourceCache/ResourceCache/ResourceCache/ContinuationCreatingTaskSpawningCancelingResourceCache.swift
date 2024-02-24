//
//  ContinuationCreatingTaskSpawningCancelingResourceCache.swift
//  ResourceCache
//
//  Created by Thomas Asheim Smedmann on 24/02/2024.
//

import Foundation

/// A concurrent and thread safe resource cache that spawns an unstructured Task to fetch a resource when the resource is first requested.
/// All Tasks requesting the resource will be suspended, and a Continuation will be created and stored for each Task.
/// Continuations and Tasks will then be resumed once the unstructured resource fetching Task has finished fetching the resource.
/// If a resource requesting Task is canceled while suspended and waiting for the unstructured resource fetching Task,
/// it will be resumed with a partially or unfinished result (empty resource in our case).
/// If all resource requesting Tasks are canceled before the unstructured resource fetching Task has finished,
/// the resource fetching Task will also be canceled (preventing unnecessary resources from being fetched).
final actor ContinuationCreatingTaskSpawningCancelingResourceCache {
    /// A thread/concurrency context safe storage for Continuations, CachedResourceState and resource fetching Task using [NSLock](https://developer.apple.com/documentation/foundation/nslock)
    private final class Locker: @unchecked Sendable {
        private var protectedWaitingContinuations: [UUID: CheckedContinuation<Data?, Never>] = [:]
        private var protectedCachedResourceState: CachedResourceState = .none
        private var protectedResourceFetchingTask: Task<Void, Never>? = nil

        private let lock = NSLock()

        var cachedResourceState: CachedResourceState {
            get { lock.withLock { protectedCachedResourceState } }
            set { lock.withLock { protectedCachedResourceState = newValue } }
        }

        var resourceFetchingTask: Task<Void, Never>? {
            get { lock.withLock { protectedResourceFetchingTask } }
            set { lock.withLock { protectedResourceFetchingTask = newValue } }
        }

        var continuationsCount: Int {
            lock.withLock { protectedWaitingContinuations.count }
        }

        func setContinuation(_ waitingContinuation: CheckedContinuation<Data?, Never>, forId id: UUID) {
            _ = lock.withLock { protectedWaitingContinuations.updateValue(waitingContinuation, forKey: id) }
        }

        func popFirstContinuation() -> (UUID, CheckedContinuation<Data?, Never>)? {
            lock.withLock { protectedWaitingContinuations.popFirst() }
        }

        func removeContinuation(forId id: UUID) -> CheckedContinuation<Data?, Never>? {
            lock.withLock { protectedWaitingContinuations.removeValue(forKey: id) }
        }
    }

    private enum CachedResourceState {
        case none
        case fetching
        case value(Data?)
    }

    private let urlSession: URLSession

    private let locker = Locker()

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
            switch locker.cachedResourceState {
                case .none:
                    locker.cachedResourceState = .fetching

                    locker.resourceFetchingTask = Task { [weak self] in
                        guard let self else {
                            return
                        }

                        var resource: Data? = nil

                        defer {
                            while let (_, waitingContinuation) = self.locker.popFirstContinuation() {
                                // Resume suspended Continuations/Tasks by returning the fetched resource.
                                // If the resource requesting Task was canceled while being suspended (this Task),
                                // resume all waiting Continuations/Tasks by returning a partially or unfinished result (empty resource in our case).
                                waitingContinuation.resume(returning: resource)
                            }
                        }

                        // One could imagine this Task having to fetch and combine multiple resources,
                        // then it might be desirable to check for cancelation before and after each chunk of async work.

                        if Task.isCancelled {
                            return
                        }

                        resource = await self.fetchResource()

                        if Task.isCancelled {
                            return
                        }

                        self.locker.cachedResourceState = .value(resource)
                    }

                    let id = UUID()

                    return await withTaskCancellationHandler {
                        await withCheckedContinuation { continuation in
                            locker.setContinuation(continuation, forId: id)
                        }
                    } onCancel: {
                        guard let waitingContinuation = locker.removeContinuation(forId: id) else {
                            return
                        }

                        // Resource requesting Task was canceled while being suspended.
                        // Resume the Continuation/Task by returning a partially or unfinished result (empty resource in our case).
                        waitingContinuation.resume(returning: nil)

                        if locker.continuationsCount > 0 {
                            return
                        }

                        locker.resourceFetchingTask?.cancel()
                    }

                case .fetching:
                    let id = UUID()

                    return await withTaskCancellationHandler {
                        await withCheckedContinuation { continuation in
                            locker.setContinuation(continuation, forId: id)
                        }
                    } onCancel: {
                        guard let waitingContinuation = locker.removeContinuation(forId: id) else {
                            return
                        }

                        // Resource requesting Task was canceled while being suspended.
                        // Resume the Continuation/Task by returning a partially or unfinished result (empty resource in our case).
                        waitingContinuation.resume(returning: nil)

                        if locker.continuationsCount > 0 {
                            return
                        }

                        locker.resourceFetchingTask?.cancel()
                    }

                case let .value(resource):
                    return resource
            }
        }
    }

    var freshResource: Data? {
        get async {
            locker.cachedResourceState = .none

            return await resource
        }
    }
}
