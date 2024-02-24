//
//  WaitingContinuationsLocker.swift
//  ResourceCache
//
//  Created by Thomas Asheim Smedmann on 24/02/2024.
//

import Foundation

/// A thread/concurrency context safe storage for Continuations using [NSLock](https://developer.apple.com/documentation/foundation/nslock).
/// Heavily inspired by this WWDC 2023 video: [Beyond the basics of structured concurrency](https://developer.apple.com/videos/play/wwdc2023/10170/).
///
/// NOTE: Be careful to always resume any suspended Continuations to prevent Continuation / Task leaks.
/// Highly recommend to check out this WWDC 2022 video: [Visualize and optimize Swift concurrency](https://developer.apple.com/videos/play/wwdc2022/110350/).
final class WaitingContinuationsLocker: @unchecked Sendable {
    private var protectedWaitingContinuations: [UUID: CheckedContinuation<Data?, Never>] = [:]
    private let lock = NSLock()

    var count: Int {
        lock.withLock { protectedWaitingContinuations.count }
    }

    func set(_ waitingContinuation: CheckedContinuation<Data?, Never>, forId id: UUID) {
        _ = lock.withLock { protectedWaitingContinuations.updateValue(waitingContinuation, forKey: id) }
    }

    func popFirst() -> (UUID, CheckedContinuation<Data?, Never>)? {
        lock.withLock { protectedWaitingContinuations.popFirst() }
    }

    func remove(forId id: UUID) -> CheckedContinuation<Data?, Never>? {
        lock.withLock { protectedWaitingContinuations.removeValue(forKey: id) }
    }
}
