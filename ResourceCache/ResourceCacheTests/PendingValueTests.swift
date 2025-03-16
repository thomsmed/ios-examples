//
//  PendingValueTests.swift
//  ResourceCacheTests
//
//  Created by Thomas Smedmann on 16/03/2025.
//

import Testing

@testable import ResourceCache

struct PendingValueTests {
    @Test func test_instantCancelation() async throws {
        let pendingValue = PendingValue<Void>()

        pendingValue.cancel()

        await #expect(throws: CancellationError.self) {
            _ = try await pendingValue.value()
        }
    }

    @Test func test_cancelation() async throws {
        let pendingValue = PendingValue<Void>()

        try await Task.sleep(for: .seconds(1))

        pendingValue.cancel()

        await #expect(throws: CancellationError.self) {
            _ = try await pendingValue.value()
        }
    }

    @Test func test_immediateCancelationAfterImmediateResolve() async throws {
        let pendingValue = PendingValue<Void>()

        pendingValue.resolve()  // In a series of immediate call to resolve/cancel, the first one wins

        pendingValue.cancel()

        pendingValue.resolve()

        _ = try await pendingValue.value()
    }

    @Test func test_cancelationAfterResolve() async throws {
        let pendingValue = PendingValue<Void>()

        try await Task.sleep(for: .seconds(1))

        pendingValue.resolve()

        pendingValue.cancel()  // Canceling should have no effect at this point

        _ = try await pendingValue.value()
    }

    @Test func test_multipleCancelationAfterResolve() async throws {
        let pendingValue = PendingValue<Void>()

        try await Task.sleep(for: .seconds(1))

        pendingValue.resolve()

        pendingValue.cancel()  // Canceling should have no effect at this point
        pendingValue.cancel()
        pendingValue.cancel()

        _ = try await pendingValue.value()
    }

    @Test func test_multipleCancelationAfterMultipleResolve() async throws {
        let pendingValue = PendingValue<Void>()

        try await Task.sleep(for: .seconds(1))

        pendingValue.resolve()  // Only the first resolve should have an effect at this point
        pendingValue.resolve()
        pendingValue.resolve()

        pendingValue.cancel()  // Canceling should have no effect at this point
        pendingValue.cancel()
        pendingValue.cancel()

        _ = try await pendingValue.value()
    }

    @Test func test_immediateResolveAfterImmediateCancelation() async throws {
        let pendingValue = PendingValue<Void>()

        pendingValue.cancel()

        pendingValue.resolve()  // Resolve should have no effect at this point

        await #expect(throws: CancellationError.self) {
            _ = try await pendingValue.value()
        }
    }

    @Test func test_multipleImmediateResolveAfterImmediateCancelation() async throws {
        let pendingValue = PendingValue<Void>()

        pendingValue.cancel()

        pendingValue.resolve()  // Resolve should have no effect at this point
        pendingValue.resolve()
        pendingValue.resolve()

        await #expect(throws: CancellationError.self) {
            _ = try await pendingValue.value()
        }
    }

    @Test func test_immediateResolve() async throws {
        let pendingValue = PendingValue<Void>()

        pendingValue.resolve()

        _ = try await pendingValue.value()
    }

    @Test func test_multipleImmediateResolve() async throws {
        let pendingValue = PendingValue<String>()

        pendingValue.resolve(returning: "First call to resolve")  // In a series of immediate call to resolve, the first one wins
        pendingValue.resolve(returning: "Second call to resolve")
        pendingValue.resolve(returning: "Third call to resolve")

        let value = try await pendingValue.value()
        #expect(value == "First call to resolve")
    }

    @Test func test_immediateResolveReturningString() async throws {
        let pendingValue = PendingValue<String>()

        pendingValue.resolve(returning: "Hello World!")

        let value = try await pendingValue.value()

        #expect(value == "Hello World!")
    }

    @Test func test_resolveReturningString() async throws {
        let pendingValue = PendingValue<String>()

        try await Task.sleep(for: .seconds(1))

        pendingValue.resolve(returning: "Hello World!")

        let value = try await pendingValue.value()

        #expect(value == "Hello World!")
    }

    @Test func test_immediateResolveThrowing() async throws {
        struct MyError: Error {}

        let pendingValue = PendingValue<String>()

        pendingValue.resolve(throwing: MyError())

        await #expect(throws: MyError.self) {
            _ = try await pendingValue.value()
        }
    }

    @Test func test_resolveThrowing() async throws {
        struct MyError: Error {}

        let pendingValue = PendingValue<String>()

        try await Task.sleep(for: .seconds(1))

        pendingValue.resolve(throwing: MyError())

        await #expect(throws: MyError.self) {
            _ = try await pendingValue.value()
        }
    }

    @Test func test_immediateResolveThrowingAndResolveReturningString() async throws {
        struct MyError: Error {}
        struct MyOtherError: Error {}

        let pendingValue = PendingValue<String>()

        pendingValue.resolve(throwing: MyError())  // In a series of immediate call to resolve, the first one wins

        pendingValue.resolve(returning: "Hello World!")

        pendingValue.resolve(throwing: MyOtherError())

        await #expect(throws: MyError.self) {
            _ = try await pendingValue.value()
        }
    }

    @Test func test_parallelResolveThrowing() async throws {
        struct MyError: Error {}

        let pendingValue = PendingValue<String>()

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                pendingValue.resolve(throwing: MyError())
            }
            group.addTask {
                pendingValue.resolve(throwing: MyError())
            }
            group.addTask {
                pendingValue.resolve(throwing: MyError())
            }
            try await group.waitForAll()
        }

        await #expect(throws: MyError.self) {
            _ = try await pendingValue.value()
        }
    }

    @Test func test_parallelResolveThrowingAndWaiting() async throws {
        struct MyError: Error {}

        let pendingValue = PendingValue<String>()

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                pendingValue.resolve(throwing: MyError())
            }
            group.addTask {
                pendingValue.resolve(throwing: MyError())
            }
            group.addTask {
                pendingValue.resolve(throwing: MyError())
            }
            group.addTask {
                await #expect(throws: MyError.self) {
                    _ = try await pendingValue.value()
                }
            }
            try await group.waitForAll()
        }
    }

    @Test func test_parallelResolveAndWaiting() async throws {
        struct MyError: Error {}

        let pendingValue = PendingValue<String>()

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                let value = try? await pendingValue.value()
                #expect(value == "Hello World!")
            }
            group.addTask {
                pendingValue.resolve(returning: "Hello World!")
            }
            group.addTask {
                let value = try? await pendingValue.value()
                #expect(value == "Hello World!")
            }
            try await group.waitForAll()
        }
    }

    @Test func test_immediateResolveWithParallelWaiting() async throws {
        struct MyError: Error {}

        let pendingValue = PendingValue<String>()

        pendingValue.resolve(returning: "Hello World!")

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                let value = try await pendingValue.value()
                #expect(value == "Hello World!")
            }
            group.addTask {
                let value = try await pendingValue.value()
                #expect(value == "Hello World!")
            }
            try await group.waitForAll()
        }
    }

    @Test func test_parallelDelayedResolveAndWaiting() async throws {
        struct MyError: Error {}

        let pendingValue = PendingValue<String>()

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                let value = try await pendingValue.value()
                #expect(value == "Hello World!")
            }
            group.addTask {
                try await Task.sleep(for: .seconds(1))
                pendingValue.resolve(returning: "Hello World!")
            }
            group.addTask {
                let value = try await pendingValue.value()
                #expect(value == "Hello World!")
            }
            try await group.waitForAll()
        }
    }

    @Test func test_parallelWaitingForString() async throws {
        struct MyError: Error {}

        let pendingValue = PendingValue<String>()

        async let values = withThrowingTaskGroup(of: String.self, returning: [String].self) { group in
            group.addTask {
                try await pendingValue.value()
            }
            group.addTask {
                try await pendingValue.value()
            }
            var values: [String] = []
            for try await value in group {
                values.append(value)
            }
            return values
        }

        try await Task.sleep(for: .seconds(1))

        pendingValue.resolve(returning: "Hello World!")

        #expect(try await values == ["Hello World!", "Hello World!"])
    }

    @Test func test_parallelWaitingForCancelation() async throws {
        struct MyError: Error {}

        let pendingValue = PendingValue<String>()

        async let nothing: Void = #expect(throws: CancellationError.self) {
            _ = try await withThrowingTaskGroup(of: String.self, returning: [String].self) { group in
                group.addTask {
                    try await pendingValue.value()
                }
                group.addTask {
                    try await pendingValue.value()
                }
                var values: [String] = []
                for try await value in group {
                    values.append(value)
                }
                return values
            }
        }

        async let anotherNothing: Void = Task.sleep(for: .seconds(1))

        pendingValue.cancel()

        _ = try await (nothing, anotherNothing)
    }

    @Test func test_waitingForCancelation() async throws {
        struct MyError: Error {}

        let pendingValue = PendingValue<String>()

        async let nothing: Void = #expect(throws: CancellationError.self) {
            try await withThrowingTaskGroup(of: String.self) { group in
                group.addTask {
                    try await pendingValue.value()
                }
                group.addTask {
                    try await pendingValue.value()
                }
                group.cancelAll()
                try await group.waitForAll()
            }
        }

        async let anotherNothing: Void = Task.sleep(for: .seconds(1))

        _ = try await (nothing, anotherNothing)
    }
}
