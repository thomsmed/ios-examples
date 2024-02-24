//
//  ContinuationCreatingCancelingResourceCacheTests.swift
//  ResourceCacheTests
//
//  Created by Thomas Asheim Smedmann on 24/02/2024.
//

import XCTest
@testable import ResourceCache

final class ContinuationCreatingCancelingResourceCacheTests: XCTestCase {
    func test_multipleResourceRequestingTasks_returnsResource() async throws {
        let resourceCache = ContinuationCreatingCancelingResourceCache()

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
        let resourceCache = ContinuationCreatingCancelingResourceCache()

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

    func test_multipleResourceRequestingTasks_cancelBeforeResult_returnsNoResource() async throws {
        let resourceCache = ContinuationCreatingCancelingResourceCache()

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

        // `ContinuationCreatingCancelingResourceCache` handles Task cancelation,
        // and will make sure that canceled resource requesting Tasks are resumed early with a partial result or no result at all.
        // But since it leverage structured concurrency (by not spawning a new Task, but creating Continuations instead),
        // canceling the first resource requesting Task will also mark any child Tasks as canceled,
        // and hence potentially cancel the resource fetching all together.
        // So if the first resource requesting Task was canceled,
        // we might expect all resource requesting Tasks to resumed early with a partial result or no result at all.
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0 == nil })
    }

    func test_multipleResourceRequestingTasks_cancelFirstBeforeResult_returnsNoResource() async throws {
        let resourceCache = ContinuationCreatingCancelingResourceCache()

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

        // `ContinuationCreatingCancelingResourceCache` handles Task cancelation,
        // and will make sure that canceled resource requesting Tasks are resumed early with a partial result or no result at all.
        // But since it leverage structured concurrency (by not spawning a new Task, but creating Continuations instead),
        // canceling the first resource requesting Task will also mark any child Tasks as canceled,
        // and hence potentially cancel the resource fetching all together.
        // So if it was the first resource requesting Task that was canceled,
        // we might expect all resource requesting Tasks to resumed early with a partial result or no result at all.
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0 == nil })
    }

    func test_multipleResourceRequestingTasks_cancelSecondAndThirdBeforeResult_returnsResource() async throws {
        let resourceCache = ContinuationCreatingCancelingResourceCache()

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

        // `ContinuationCreatingCancelingResourceCache` handles Task cancelation,
        // and will make sure that canceled resource requesting Tasks are resumed early with a partial result or no result at all.
        // But since it leverage structured concurrency (by not spawning a new Task, but creating Continuations instead),
        // canceling the first resource requesting Task will also mark any child Tasks as canceled,
        // and hence potentially cancel the resource fetching all together.
        // So if it was not the first resource requesting Task that was canceled,
        // we expect canceled resource requesting Tasks to resumed early with a partial result or no result at all,
        // and non-canceled resource requesting Tasks to to wait for the resource as normal.
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.filter { $0 == nil }.count, 2)
        XCTAssertEqual(results.filter { $0 != nil }.count, 3)
    }
}
