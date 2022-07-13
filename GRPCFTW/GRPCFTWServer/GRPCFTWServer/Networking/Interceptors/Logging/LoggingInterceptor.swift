//
//  LoggingInterceptor.swift
//  GRPCFTWServer
//
//  Created by Thomas Asheim Smedmann on 25/06/2022.
//

import NIO
import GRPC

final class LoggingInterceptor: ServerInterceptor<Grpcftw_ListBarRequest, Grpcftw_GetBarResponse> {

    override func send(_ part: GRPCServerResponsePart<Grpcftw_GetBarResponse>, promise: EventLoopPromise<Void>?, context: ServerInterceptorContext<Grpcftw_ListBarRequest, Grpcftw_GetBarResponse>) {
        context.send(part, promise: promise)
    }

    override func receive(_ part: GRPCServerRequestPart<Grpcftw_ListBarRequest>, context: ServerInterceptorContext<Grpcftw_ListBarRequest, Grpcftw_GetBarResponse>) {
        context.receive(part)
    }
}
