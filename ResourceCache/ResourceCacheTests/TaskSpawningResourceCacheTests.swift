//
//  TaskSpawningResourceCacheTests.swift
//  ResourceCacheTests
//
//  Created by Thomas Asheim Smedmann on 24/02/2024.
//

import XCTest
@testable import ResourceCache

final class TaskSpawningResourceCacheTests: XCTestCase {
    func test_multipleResourceRequestingTasks_returnsResource() async throws {
        let resourceCache = TaskSpawningResourceCache()

        var resourceRequestingTasks: [Task<Data?, Never>] = []
        for _ in (0..<5) {
            // Slightly delay Task creation so that Task scheduling order have a higher chance of being the same as the creation order.
            try await Task.sleep(for: .microseconds(1))

            resourceRequestingTasks.append(
                Task.detached {
                    return await resourceCache.resource
                }
            )
        }

        var results: [Data?] = []
        for resourceRequestingTask in resourceRequestingTasks {
            results.append(await resourceRequestingTask.value)
        }

        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0 != nil })
    }

    func test_multipleResourceRequestingTasks_cancelAfterResult_returnsResource() async throws {
        let resourceCache = TaskSpawningResourceCache()

        var resourceRequestingTasks: [Task<Data?, Never>] = []
        for _ in (0..<5) {
            // Slightly delay Task creation so that Task scheduling order have a higher chance of being the same as the creation order.
            try await Task.sleep(for: .microseconds(1))

            resourceRequestingTasks.append(
                Task.detached {
                    return await resourceCache.resource
                }
            )
        }

        var results: [Data?] = []
        var cancel: Bool = true
        for resourceRequestingTask in resourceRequestingTasks {
            results.append(await resourceRequestingTask.value)

            guard cancel else {
                continue
            }

            cancel = false

            for resourceRequestingTask in resourceRequestingTasks {
                resourceRequestingTask.cancel()
            }
        }

        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0 != nil })
    }

    func test_multipleResourceRequestingTasks_cancelBeforeResult_returnsResource() async throws {
        let resourceCache = TaskSpawningResourceCache()

        var resourceRequestingTasks: [Task<Data?, Never>] = []
        for _ in (0..<5) {
            // Slightly delay Task creation so that Task scheduling order have a higher chance of being the same as the creation order.
            try await Task.sleep(for: .microseconds(1))

            resourceRequestingTasks.append(
                Task.detached {
                    return await resourceCache.resource
                }
            )
        }

        try await Task.sleep(for: .milliseconds(1))

        for resourceRequestingTask in resourceRequestingTasks {
            resourceRequestingTask.cancel()
        }

        var results: [Data?] = []
        for resourceRequestingTask in resourceRequestingTasks {
            results.append(await resourceRequestingTask.value)
        }

        // `TaskSpawningResourceCache` does not handle Task cancelation,
        // so we expect all Tasks to wait for the resource even though they where marked as canceled.
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0 != nil })
    }

    func test_multipleResourceRequestingTasks_cancelFirstBeforeResult_returnsResource() async throws {
        let resourceCache = TaskSpawningResourceCache()

        var resourceRequestingTasks: [Task<Data?, Never>] = []
        for _ in (0..<5) {
            // Slightly delay Task creation so that Task scheduling order have a higher chance of being the same as the creation order.
            try await Task.sleep(for: .microseconds(1))

            resourceRequestingTasks.append(
                Task.detached {
                    return await resourceCache.resource
                }
            )
        }

        try await Task.sleep(for: .milliseconds(1))

        resourceRequestingTasks[0].cancel()

        var results: [Data?] = []
        for resourceRequestingTask in resourceRequestingTasks {
            results.append(await resourceRequestingTask.value)
        }

        // `TaskSpawningResourceCache` does not handle Task cancelation,
        // so we expect all Tasks to wait for the resource even though some where marked as canceled.
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0 != nil })
    }

    func test_multipleResourceRequestingTasks_cancelSecondAndThirdBeforeResult_returnsResource() async throws {
        let resourceCache = TaskSpawningResourceCache()

        var resourceRequestingTasks: [Task<Data?, Never>] = []
        for _ in (0..<5) {
            // Slightly delay Task creation so that Task scheduling order have a higher chance of being the same as the creation order.
            try await Task.sleep(for: .microseconds(1))

            resourceRequestingTasks.append(
                Task.detached {
                    return await resourceCache.resource
                }
            )
        }

        try await Task.sleep(for: .milliseconds(1))

        resourceRequestingTasks[1].cancel()
        resourceRequestingTasks[2].cancel()

        var results: [Data?] = []
        for resourceRequestingTask in resourceRequestingTasks {
            results.append(await resourceRequestingTask.value)
        }

        // `TaskSpawningResourceCache` does not handle Task cancelation,
        // so we expect all Tasks to wait for the resource even though they where marked as canceled.
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0 != nil })
    }
}
