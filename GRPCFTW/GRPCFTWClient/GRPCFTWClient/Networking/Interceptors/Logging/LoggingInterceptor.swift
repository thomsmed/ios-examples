//
//  LoggingInterceptor.swift
//  GRPCFTWClient
//
//  Created by Thomas Asheim Smedmann on 25/06/2022.
//

import NIO
import GRPC

final class LoggingInterceptor<Request, Response>: ClientInterceptor<Request, Response> {

    override func send(_ part: GRPCClientRequestPart<Request>, promise: EventLoopPromise<Void>?, context: ClientInterceptorContext<Request, Response>) {
        switch part {
        case let .metadata(headers):
            print("> Starting '\(context.path)', headers: \(headers)")
        case let .message(request, metadata):
            print("> Sending '\(context.path)'")
        case .end:
            print("> Closing '\(context.path)'")
        }

        // Forward the request part to the next interceptor.
        context.send(part, promise: promise)
    }

    override func receive(_ part: GRPCClientResponsePart<Response>, context: ClientInterceptorContext<Request, Response>) {
        switch part {
        case let .metadata(headers):
            print("< Received '\(context.path)', headers: \(headers)")

        case let .message(response):
            print("< Received '\(context.path)'")

        case let .end(status, trailers):
            print("< Closed '\(context.path)', status: '\(status)' and trailers: \(trailers)")
        }

        // Forward the response part to the next interceptor.
        context.receive(part)
    }
}
