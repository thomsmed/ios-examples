//
//  PendingOperation.swift
//  ResourceCache
//
//  Created by Thomas Smedmann on 09/03/2025.
//

import Foundation

/// A utility type for letting multiple caller Tasks wait for a future value produced by an asynchronous operation.
public final class PendingOperation<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()

    private var result: Result<T, any Error>?
    private var operationTask: Task<Void, any Error>?
    private var waitingContinuations: [UUID: CheckedContinuation<T, any Error>] = [:]

    public init(_ operation: @escaping @Sendable () async throws -> T) {
        operationTask = .detached {
            do {
                let value = try await operation()
                self.resolve(with: .success(value))
            } catch {
                self.resolve(with: .failure(error))
            }
        }
    }

    deinit {
        assert(waitingContinuations.isEmpty, "Expecting all pending continuations to be fulfilled")
    }

    /// Resolve this ``PendingOperation`` by returning `result`. Waiting Tasks will be notified immediately.
    private func resolve(with result: Result<T, any Error>) {
        let continuations = lock.withLock {
            if self.result != nil {
                // Should only be allowed to resolve once.
                return [CheckedContinuation<T, any Error>]()
            }

            self.result = result
            let continuations = self.waitingContinuations.map { $1 }
            self.waitingContinuations.removeAll()
            return continuations
        }

        // Must not resume the continuations while holding the lock!
        for continuation in continuations {
            continuation.resume(with: result)
        }
    }

    public var isCompleted: Bool {
        lock.withLock {
            self.result != nil
        }
    }

    public var isCanceled: Bool {
        lock.withLock {
            self.operationTask?.isCancelled ?? false
        }
    }

    /// Wait for the future value. Task cancelation is handled as expected.
    public func value() async throws -> T {
        let id = UUID()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                do {
                    let readyResult: Result<T, any Error>? = try lock.withLock {
                        try Task.checkCancellation()

                        if let readyResult = self.result {
                            return readyResult
                        } else {
                            self.waitingContinuations[id] = continuation
                            return nil
                        }
                    }

                    if let readyResult {
                        // Must not resume the continuation while holding the lock!
                        continuation.resume(with: readyResult)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        } onCancel: {
            let continuation = lock.withLock {
                self.waitingContinuations.removeValue(forKey: id)
            }

            // Must not resume the continuation while holding the lock!
            continuation?.resume(throwing: CancellationError())
        }
    }

    /// Cancel this ``PendingOperation``.
    public func cancel() {
        lock.withLock {
            self.operationTask?.cancel()
        }
    }
}
