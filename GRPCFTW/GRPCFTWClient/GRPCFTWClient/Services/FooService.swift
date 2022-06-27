//
//  FooService.swift
//  GRPCFTWClient
//
//  Created by Thomas Asheim Smedmann on 25/06/2022.
//

import NIO
import GRPC

protocol FooService: AnyObject {

    func listFoo(_ completion: @escaping (Result<Void, Error>) -> Void)
    func getFoo(_ completion: @escaping (Result<Void, Error>) -> Void)
}

final class DefaultFooService {

    private let fooServiceClient: Grpcftw_FooServiceClientProtocol
    private let authTokenProvider: AuthTokenProvider

    init(clientFactory: ClientFactory, authTokenProvider: AuthTokenProvider) {
        self.fooServiceClient = clientFactory.fooServiceClient()
        self.authTokenProvider = authTokenProvider
    }
}

extension DefaultFooService: FooService {

    func listFoo(_ completion: @escaping (Result<Void, Error>) -> Void) {

        fooServiceClient.makeStreamingCallWithRetry(
            fooServiceClient.listFoo,
            Grpcftw_ListFooRequest(),
            handler: { _ in },
            shouldRetry: { error in
                if let grpcStatus = error as? GRPCStatus {
                    return grpcStatus.code == .unavailable
                }
                return false
            },
            retries: 2
        ).whenComplete { result in
            print(result)
        }
    }

    func getFoo(_ completion: @escaping (Result<Void, Error>) -> Void) {

        authTokenProvider.freshAuthToken()
            .flatMap { accessToken in
                self.fooServiceClient.getFoo(Grpcftw_GetFooRequest()).response
            }
            .whenComplete { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case let .success(response):
                    completion(.success(()))
                }
            }
    }
}
