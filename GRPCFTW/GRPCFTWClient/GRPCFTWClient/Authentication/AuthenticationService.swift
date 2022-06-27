//
//  AuthenticationService.swift
//  GRPCFTWClient
//
//  Created by Thomas Asheim Smedmann on 25/06/2022.
//

import NIOCore

protocol AuthTokenProvider: AnyObject {

    var currentAuthToken: String? { get }

    func freshAuthToken(_ completion: @escaping (Result<String, AuthTokenProviderError>) -> Void)
    func freshAuthToken() -> EventLoopFuture<String>
}

enum AuthTokenProviderError: Error {
    case notAuthenticated
}

protocol AuthenticationService: AnyObject {

}

final class DefaultAuthenticationService {

    private let eventLoopProvider: EventLoopProvider

    init(eventLoopProvider: EventLoopProvider) {
        self.eventLoopProvider = eventLoopProvider
    }
}

// MARK: AuthenticationService

extension DefaultAuthenticationService: AuthenticationService {

}

// MARK: AuthTokenProvider

extension DefaultAuthenticationService: AuthTokenProvider {

    var currentAuthToken: String? {
        "<a-valid-access-token>"
    }

    func freshAuthToken(_ completion: @escaping (Result<String, AuthTokenProviderError>) -> Void) {
        // Call the completion with a success result containing a valid access token, refreshing it if necessary
        completion(.success("<a-valid-access-token>"))

        // Or call the completion with a failure result if an access token is not possible to obtain
        // completion(.failure(SomeError))
    }

    func freshAuthToken() -> EventLoopFuture<String> {
        let promise: EventLoopPromise<String> = eventLoopProvider.eventLoop.makePromise()

        // Succeed the promise with a valid access token, refreshing it if necessary
        promise.succeed("<a-valid-access-token>")

        // Or fail the promise if an access token is not possible to obtain
        // promise.fail(SomeError)

        return promise.futureResult
    }
}
