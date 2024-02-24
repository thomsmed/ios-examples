//
//  AtomicCount.swift
//  ResourceCache
//
//  Created by Thomas Asheim Smedmann on 24/02/2024.
//

import Foundation
import Atomics

/// A thread/concurrency context safe value using [Swift Atomics](https://github.com/apple/swift-atomics).
/// Heavily inspired by this WWDC 2023 video: [Beyond the basics of structured concurrency](https://developer.apple.com/videos/play/wwdc2023/10170/).
final class AtomicCount: Sendable {
    private let protectedValue = ManagedAtomic<Int>(0)

    var value: Int {
        protectedValue.load(ordering: .acquiring)
    }

    func increment() {
        protectedValue.wrappingIncrement(ordering: .relaxed)
    }

    func decrement() {
        protectedValue.wrappingDecrement(ordering: .relaxed)
    }

    func reset() {
        protectedValue.store(0, ordering: .relaxed)
    }
}
