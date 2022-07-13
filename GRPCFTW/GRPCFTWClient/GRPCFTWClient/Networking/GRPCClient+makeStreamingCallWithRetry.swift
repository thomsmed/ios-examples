//
//  GRPCClient+makeStreamingCallWithRetry.swift
//  GRPCFTWClient
//
//  Created by Thomas Asheim Smedmann on 25/06/2022.
//

import NIO
import GRPC

extension GRPCClient {

    func makeStreamingCallWithRetry<Request, Response>(
        _ streamingFunction: @escaping (Request, CallOptions?, @escaping (Response) -> Void) -> ServerStreamingCall<Request, Response>,
        _ request: Request,
        callOptions: CallOptions? = nil,
        handler: @escaping (Response) -> Void,
        shouldRetry: @escaping (Error) -> Bool = { _ in true },
        retries: Int = 1
    ) -> EventLoopFuture<GRPCStatus> {
        let streamingCall = streamingFunction(request, callOptions, handler)
        let eventLoop = streamingCall.eventLoop
        return streamingCall.status
            .flatMapError { error in
                guard retries > 0 else {
                    return eventLoop.makeFailedFuture(error)
                }

                guard shouldRetry(error) else {
                    return eventLoop.makeFailedFuture(error)
                }

                return makeStreamingCallWithRetry(
                    streamingFunction,
                    request,
                    callOptions: callOptions,
                    handler: handler,
                    shouldRetry: shouldRetry,
                    retries: retries - 1
                )
            }
    }
}
