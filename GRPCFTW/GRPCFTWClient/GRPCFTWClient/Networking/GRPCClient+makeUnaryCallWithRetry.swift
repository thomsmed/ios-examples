//
//  GRPCClient+makeUnaryCallWithRetry.swift
//  GRPCFTWClient
//
//  Created by Thomas Asheim Smedmann on 25/06/2022.
//

import NIO
import GRPC

extension GRPCClient {

    func makeUnaryCallWithRetry<Request, Response>(
        _ unaryFunction: @escaping (Request, CallOptions?) -> UnaryCall<Request, Response>,
        _ request: Request,
        callOptions: CallOptions? = nil,
        shouldRetry: @escaping (Error) -> Bool = { _ in true },
        retries: Int = 1
    ) -> EventLoopFuture<Response> {
        let unaryCall = unaryFunction(request, callOptions)
        let eventLoop = unaryCall.eventLoop
        return unaryCall.response
            .flatMapError { error in
                guard retries > 0 else {
                    return eventLoop.makeFailedFuture(error)
                }

                guard shouldRetry(error) else {
                    return eventLoop.makeFailedFuture(error)
                }

                return self.makeUnaryCallWithRetry(
                    unaryFunction,
                    request,
                    callOptions: callOptions,
                    shouldRetry: shouldRetry,
                    retries: retries - 1
                )
            }
    }
}
