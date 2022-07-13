//
//  DefaultFooServiceProvider.swift
//  GRPCFTWServer
//
//  Created by Thomas Asheim Smedmann on 25/06/2022.
//

import NIO
import GRPC

final class DefaultFooServiceProvider {

}

// MARK: Grpcftw_FooServiceProvider

extension DefaultFooServiceProvider: Grpcftw_FooServiceProvider {
    var interceptors: Grpcftw_FooServiceServerInterceptorFactoryProtocol? {
        nil
    }

    func listFoo(
        request: Grpcftw_ListFooRequest,
        context: StreamingResponseCallContext<Grpcftw_GetFooResponse>
    ) -> EventLoopFuture<GRPCStatus> {
        context.sendResponse(.init()).whenComplete { result in
            context.statusPromise.completeWith(.success(.ok))
        }
        return context.statusPromise.futureResult
    }

    func getFoo(
        request: Grpcftw_GetFooRequest,
        context: StatusOnlyCallContext
    ) -> EventLoopFuture<Grpcftw_GetFooResponse> {
        return context.eventLoop.makeCompletedFuture(.success(.init()))
    }

    func setFoo(
        request: Grpcftw_SetFooRequest,
        context: StatusOnlyCallContext
    ) -> EventLoopFuture<Grpcftw_SetFooResponse> {
        return context.eventLoop.makeCompletedFuture(.success(.init()))
    }

    func updateFoo(
        request: Grpcftw_UpdateFooRequest,
        context: StatusOnlyCallContext
    ) -> EventLoopFuture<Grpcftw_UpdateFooResponse> {
        return context.eventLoop.makeCompletedFuture(.success(.init()))
    }

    func deleteFoo(
        request: Grpcftw_DeleteFooRequest,
        context: StatusOnlyCallContext
    ) -> EventLoopFuture<Grpcftw_DeleteFooResponse> {
        return context.eventLoop.makeCompletedFuture(.success(.init()))
    }
}
