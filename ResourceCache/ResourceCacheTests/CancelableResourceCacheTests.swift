//
//  CancelableResourceCacheTests.swift
//  ResourceCacheTests
//
//  Created by Thomas Asheim Smedmann on 24/02/2024.
//

import XCTest

@testable import ResourceCache

final class CancelableResourceCacheTests: XCTestCase {
    func test_multipleResourceRequestingTasks_returnsResource() async throws {
        let resourceCache = CancelableResourceCache()

        var resourceRequestingTasks: [Task<Data?, Never>] = []
        for _ in (0..<5) {
            resourceRequestingTasks.append(
                Task.detached {
                    try? await Task.sleep(for: .milliseconds(1))

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
        let resourceCache = CancelableResourceCache()

        var resourceRequestingTasks: [Task<Data?, Never>] = []
        for _ in (0..<5) {
            resourceRequestingTasks.append(
                Task.detached {
                    try? await Task.sleep(for: .milliseconds(1))

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
        let resourceCache = CancelableResourceCache()

        var resourceRequestingTasks: [Task<Data?, Never>] = []
        for _ in (0..<5) {
            resourceRequestingTasks.append(
                Task.detached {
                    try? await Task.sleep(for: .milliseconds(1))

                    return await resourceCache.resource
                }
            )
        }

        for resourceRequestingTask in resourceRequestingTasks {
            resourceRequestingTask.cancel()
        }

        var results: [Data?] = []
        for resourceRequestingTask in resourceRequestingTasks {
            results.append(await resourceRequestingTask.value)
        }

        // `CancelableResourceCache` handles Task cancelation,
        // and will make sure that canceled resource requesting Tasks are resumed early with a partial result or no result at all.
        // Since it spawns an unstructured resource fetching Task, it is able to manage canceled resource requesting Tasks individually, and have canceled resource requesting Tasks resumed early with a partial result or no result at all.
        // So we expect canceled resource requesting Tasks to resumed early with a partial result or no result at all,
        // and non-canceled resource requesting Tasks to to wait for the resource as normal.
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0 == nil })
    }

    func test_multipleResourceRequestingTasks_cancelFirstBeforeResult_returnsResource() async throws {
        let resourceCache = CancelableResourceCache()

        var resourceRequestingTasks: [Task<Data?, Never>] = []
        for _ in (0..<5) {
            resourceRequestingTasks.append(
                Task.detached {
                    try? await Task.sleep(for: .milliseconds(1))

                    return await resourceCache.resource
                }
            )
        }

        resourceRequestingTasks[0].cancel()

        var results: [Data?] = []
        for resourceRequestingTask in resourceRequestingTasks {
            results.append(await resourceRequestingTask.value)
        }

        // `CancelableResourceCache` handles Task cancelation,
        // and will make sure that canceled resource requesting Tasks are resumed early with a partial result or no result at all.
        // Since it spawns an unstructured resource fetching Task, it is able to manage canceled resource requesting Tasks individually, and have canceled resource requesting Tasks resumed early with a partial result or no result at all.
        // So we expect canceled resource requesting Tasks to resumed early with a partial result or no result at all,
        // and non-canceled resource requesting Tasks to to wait for the resource as normal.
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.filter { $0 == nil }.count, 1)
        XCTAssertEqual(results.filter { $0 != nil }.count, 4)
    }

    func test_multipleResourceRequestingTasks_cancelSecondAndThirdBeforeResult_returnsResource() async throws {
        let resourceCache = CancelableResourceCache()

        var resourceRequestingTasks: [Task<Data?, Never>] = []
        for _ in (0..<5) {
            resourceRequestingTasks.append(
                Task.detached {
                    try? await Task.sleep(for: .milliseconds(1))

                    return await resourceCache.resource
                }
            )
        }

        resourceRequestingTasks[1].cancel()
        resourceRequestingTasks[2].cancel()

        var results: [Data?] = []
        for resourceRequestingTask in resourceRequestingTasks {
            results.append(await resourceRequestingTask.value)
        }

        // `CancelableResourceCache` handles Task cancelation,
        // and will make sure that canceled resource requesting Tasks are resumed early with a partial result or no result at all.
        // Since it spawns an unstructured resource fetching Task, it is able to manage canceled resource requesting Tasks individually, and have canceled resource requesting Tasks resumed early with a partial result or no result at all.
        // So we expect canceled resource requesting Tasks to resumed early with a partial result or no result at all,
        // and non-canceled resource requesting Tasks to to wait for the resource as normal.
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.filter { $0 == nil }.count, 2)
        XCTAssertEqual(results.filter { $0 != nil }.count, 3)
    }
}
