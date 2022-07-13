//
//  AuthTokenInterceptor.swift
//  GRPCFTWClient
//
//  Created by Thomas Asheim Smedmann on 27/06/2022.
//

import NIO
import GRPC

final class AuthTokenInterceptor<Request, Response>: ClientInterceptor<Request, Response> {

    private let authTokenProvider: AuthTokenProvider

    init(authTokenProvider: AuthTokenProvider) {
        self.authTokenProvider = authTokenProvider
    }

    override func send(_ part: GRPCClientRequestPart<Request>, promise: EventLoopPromise<Void>?, context: ClientInterceptorContext<Request, Response>) {
        guard case .metadata(var headers) = part else {
            return context.send(part, promise: promise)
        }

        if let authToken = authTokenProvider.currentAuthToken {
            headers.add(name: "authorization", value: authToken)
            context.send(.metadata(headers), promise: promise)
        } else {
            context.errorCaught(AuthTokenProviderError.notAuthenticated)
        }
    }
}
