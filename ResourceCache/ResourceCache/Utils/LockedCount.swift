//
//  LockedCount.swift
//  ResourceCache
//
//  Created by Thomas Asheim Smedmann on 24/02/2024.
//

import Foundation

/// A thread/concurrency context safe value using [NSLock](https://developer.apple.com/documentation/foundation/nslock).
/// Heavily inspired by this WWDC 2023 video: [Beyond the basics of structured concurrency](https://developer.apple.com/videos/play/wwdc2023/10170/).
final class LockedCount: @unchecked Sendable {
    private let lock = NSLock()
    private var protectedValue = 0

    var value: Int {
        lock.withLock { protectedValue }
    }

    func increment() {
        lock.withLock { protectedValue += 1 }
    }

    func decrement() {
        lock.withLock { protectedValue -= 1 }
    }

    func reset() {
        lock.withLock { protectedValue = 0 }
    }
}
