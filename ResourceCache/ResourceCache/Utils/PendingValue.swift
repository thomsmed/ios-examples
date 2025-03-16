//
//  PendingValue.swift
//  ResourceCache
//
//  Created by Thomas Smedmann on 09/03/2025.
//

import Foundation

/// A utility type for letting multiple caller Tasks wait for a future value, whom exact arrival is unknown and will be manually triggered some time in the future.
public final class PendingValue<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()

    private var result: Result<T, any Error>?
    private var waitingContinuations: [UUID: CheckedContinuation<T, any Error>] = [:]

    public init() {}

    deinit {
        assert(waitingContinuations.isEmpty, "Expecting all pending continuations to be fulfilled")
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

    /// Resolve this ``PendingValue`` by returning `result`. Waiting Tasks will be notified immediately.
    public func resolve(with result: Result<T, any Error>) {
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
}

public extension PendingValue {
    /// Resolve this ``PendingValue`` by returning `value`. Waiting Tasks will be notified immediately.
    func resolve(returning value: T) {
        resolve(with: .success(value))
    }

    /// Resolve this ``PendingValue`` by throwing `error`. Waiting Tasks will be notified immediately.
    func resolve(throwing error: any Error) {
        resolve(with: .failure(error))
    }

    /// Resolve this ``PendingValue`` by throwing ``CancellationError``. Waiting Tasks will be notified immediately.
    func cancel() {
        resolve(throwing: CancellationError())
    }
}

public extension PendingValue where T == Void {
    /// Resolve this ``PendingValue``. Waiting Tasks will be notified immediately.
    func resolve() {
        resolve(returning: Void())
    }
}
