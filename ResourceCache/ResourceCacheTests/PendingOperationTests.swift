//
//  PendingOperationTests.swift
//  ResourceCacheTests
//
//  Created by Thomas Smedmann on 16/03/2025.
//

import Testing

@testable import ResourceCache

struct PendingOperationTests {
    @Test func test_instantCancelation() async throws {
        let pendingOperation = PendingOperation<Void> {
            try await Task.sleep(for: .seconds(1))
        }

        #expect(!pendingOperation.isCompleted)

        pendingOperation.cancel()

        #expect(pendingOperation.isCanceled)
        #expect(!pendingOperation.isCompleted)

        await #expect(throws: CancellationError.self) {
            _ = try await pendingOperation.value()
        }

        #expect(pendingOperation.isCompleted)
    }

    @Test func test_cancelation() async throws {
        let pendingOperation = PendingOperation<Void> {
            try await Task.sleep(for: .seconds(5))
        }

        #expect(!pendingOperation.isCompleted)

        try await Task.sleep(for: .seconds(1))

        pendingOperation.cancel()

        #expect(pendingOperation.isCanceled)
        #expect(!pendingOperation.isCompleted)

        await #expect(throws: CancellationError.self) {
            _ = try await pendingOperation.value()
        }

        #expect(pendingOperation.isCompleted)
    }

    @Test func test_cancelationAfterCompleted() async throws {
        let pendingOperation = PendingOperation<Void> {
            try Task.checkCancellation()
        }

        #expect(!pendingOperation.isCanceled)
        #expect(!pendingOperation.isCompleted)

        try await Task.sleep(for: .seconds(1))

        #expect(!pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)

        pendingOperation.cancel()  // Canceling has no effect after the PendingOperation has completed

        #expect(pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)

        _ = try await pendingOperation.value()

        #expect(pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)
    }

    @Test func test_multipleCancelationAfterCompleted() async throws {
        let pendingOperation = PendingOperation<Void> {
            try Task.checkCancellation()
        }

        #expect(!pendingOperation.isCanceled)
        #expect(!pendingOperation.isCompleted)

        try await Task.sleep(for: .seconds(1))

        pendingOperation.cancel()  // Canceling has no effect after the PendingOperation has completed
        pendingOperation.cancel()
        pendingOperation.cancel()

        #expect(pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)

        _ = try await pendingOperation.value()

        #expect(pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)
    }

    @Test func test_immediateCancelationOnCancelationIgnoringOperation() async throws {
        let pendingOperation = PendingOperation<Void> {
            try? Task.checkCancellation() // Operation ignores cancelation
        }

        #expect(!pendingOperation.isCanceled)
        #expect(!pendingOperation.isCompleted)

        pendingOperation.cancel()

        #expect(pendingOperation.isCanceled)
        #expect(!pendingOperation.isCompleted)

        _ = try await pendingOperation.value()

        #expect(pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)
    }

    @Test func test_immediateCompletion() async throws {
        let pendingOperation = PendingOperation<Void> {
            try Task.checkCancellation()
        }

        #expect(!pendingOperation.isCanceled)
        #expect(!pendingOperation.isCompleted)

        _ = try await pendingOperation.value()

        #expect(!pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)
    }

    @Test func test_immediateCompletionReturningString() async throws {
        let pendingOperation = PendingOperation<String> {
            "Hello World!"
        }

        #expect(!pendingOperation.isCanceled)
        #expect(!pendingOperation.isCompleted)

        let value = try await pendingOperation.value()

        #expect(!pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)

        #expect(value == "Hello World!")
    }

    @Test func test_resolveReturningString() async throws {
        let pendingOperation = PendingOperation<String> {
            "Hello World!"
        }

        #expect(!pendingOperation.isCanceled)
        #expect(!pendingOperation.isCompleted)

        try await Task.sleep(for: .seconds(1))

        #expect(!pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)

        let value = try await pendingOperation.value()

        #expect(!pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)

        #expect(value == "Hello World!")
    }

    @Test func test_immediateCompletionThrowing() async throws {
        struct MyError: Error {}

        let pendingOperation = PendingOperation<String> {
            throw MyError()
        }

        #expect(!pendingOperation.isCanceled)
        #expect(!pendingOperation.isCompleted)

        await #expect(throws: MyError.self) {
            _ = try await pendingOperation.value()
        }

        #expect(!pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)
    }

    @Test func test_resolveThrowing() async throws {
        struct MyError: Error {}

        let pendingOperation = PendingOperation<String> {
            throw MyError()
        }

        #expect(!pendingOperation.isCanceled)
        #expect(!pendingOperation.isCompleted)

        try await Task.sleep(for: .seconds(1))

        #expect(!pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)

        await #expect(throws: MyError.self) {
            _ = try await pendingOperation.value()
        }

        #expect(!pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)
    }

    @Test func test_parallelThrowing() async throws {
        struct MyError: Error {}

        let pendingOperation = PendingOperation<String> {
            throw MyError()
        }

        #expect(!pendingOperation.isCanceled)
        #expect(!pendingOperation.isCompleted)

        await #expect(throws: MyError.self) {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    _ = try await pendingOperation.value()
                }
                group.addTask {
                    _ = try await pendingOperation.value()
                }
                group.addTask {
                    _ = try await pendingOperation.value()
                }
                try await group.waitForAll()
            }
        }

        #expect(!pendingOperation.isCanceled)
        #expect(pendingOperation.isCompleted)
    }

    @Test func test_parallelReturningString() async throws {
        struct MyError: Error {}

        let pendingOperation = PendingOperation<String> {
            "Hello World!"
        }

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                let value = try await pendingOperation.value()
                #expect(value == "Hello World!")
            }
            group.addTask {
                let value = try await pendingOperation.value()
                #expect(value == "Hello World!")
            }
            group.addTask {
                let value = try await pendingOperation.value()
                #expect(value == "Hello World!")
            }
            try await group.waitForAll()
        }
    }

    @Test func test_parallelDelayedReturningString() async throws {
        struct MyError: Error {}

        let pendingOperation = PendingOperation<String> {
            try await Task.sleep(for: .seconds(1))
            return "Hello World!"
        }

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                let value = try await pendingOperation.value()
                #expect(value == "Hello World!")
            }
            group.addTask {
                let value = try await pendingOperation.value()
                #expect(value == "Hello World!")
            }
            group.addTask {
                let value = try await pendingOperation.value()
                #expect(value == "Hello World!")
            }
            try await group.waitForAll()
        }
    }

    @Test func test_parallelWaitingForString() async throws {
        struct MyError: Error {}

        let pendingOperation = PendingOperation<String> {
            "Hello World!"
        }

        async let values = withThrowingTaskGroup(of: String.self, returning: [String].self) { group in
            group.addTask {
                try await pendingOperation.value()
            }
            group.addTask {
                try await pendingOperation.value()
            }
            var values: [String] = []
            for try await value in group {
                values.append(value)
            }
            return values
        }

        #expect(try await values == ["Hello World!", "Hello World!"])
    }
}
