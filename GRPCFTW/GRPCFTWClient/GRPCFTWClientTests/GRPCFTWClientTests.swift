//
//  GRPCFTWClientTests.swift
//  GRPCFTWClientTests
//
//  Created by Thomas Asheim Smedmann on 30/06/2022.
//

import XCTest
import NIO
import GRPC

@testable import GRPCFTWClient

class FooServiceTests: XCTestCase {

    final class DummyEventLoopProvider: EventLoopProvider {

        let embeddedEventLoop = EmbeddedEventLoop()

        var eventLoop: EventLoop {
            embeddedEventLoop.any()
        }
    }

    private let eventLoopProvider = DummyEventLoopProvider()

    private let fooServiceTestClient = Grpcftw_FooServiceTestClient()

    // ...

    func testFreshAuthToken() throws {
        let authenticationService = DefaultAuthenticationService(
            eventLoopProvider: eventLoopProvider
        )

        // Note: Normally you would avoid using .wait().
        let authToken = try authenticationService.freshAuthToken().wait()

        XCTAssertFalse(authToken.isEmpty)
    }

    func testGetFooFails() throws {
        // Not enqueueing a GetFoo response will fail the call

        let fooService = DefaultFooService(fooServiceClient: fooServiceTestClient)

        var fooResult: Result<Void, Error>?
        fooService.getFoo() { result in
            // Note: The test client stub will call this synchronous on the calling thread,
            // so its not necessary to use the asynchronous test APIs.
            // Check out this article for more info about asynchronous testing:
            // - https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations
            fooResult = result
        }

        XCTAssertNotNil(fooResult)
        if case .success = fooResult! {
            XCTFail()
        }
    }

    func testGetFooSucceeds() throws {
        fooServiceTestClient.enqueueGetFooResponse(.init())

        let fooService = DefaultFooService(fooServiceClient: fooServiceTestClient)

        var fooResult: Result<Void, Error>?
        fooService.getFoo() { result in
            // Note: The test client stub will call this synchronous on the calling thread,
            // so its not necessary to use the asynchronous test APIs.
            // Check out this article for more info about asynchronous testing:
            // - https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations
            fooResult = result
        }

        XCTAssertNotNil(fooResult)
        if case .failure = fooResult! {
            XCTFail()
        }
    }

    // ...

}
