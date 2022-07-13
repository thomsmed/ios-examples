//
//  DefaultBarServiceProvider.swift
//  GRPCFTWServer
//
//  Created by Thomas Asheim Smedmann on 06/06/2022.
//

import NIO
import GRPC

final class DefaultBarServiceProvider {

}

// MARK: Grpcftw_BarServiceProvider

extension DefaultBarServiceProvider: Grpcftw_BarServiceProvider {

    var interceptors: Grpcftw_BarServiceServerInterceptorFactoryProtocol? {
        nil
    }

    func listBar(
        request: Grpcftw_ListBarRequest,
        context: StreamingResponseCallContext<Grpcftw_GetBarResponse>
    ) -> EventLoopFuture<GRPCStatus> {
        context.sendResponse(.init()).whenComplete { result in
            context.statusPromise.completeWith(.success(.ok))
        }
        return context.statusPromise.futureResult
    }

    func getBar(
        request: Grpcftw_GetBarRequest,
        context: StatusOnlyCallContext
    ) -> EventLoopFuture<Grpcftw_GetBarResponse> {
        return context.eventLoop.makeCompletedFuture(.success(.init()))
    }

    func setBar(
        request: Grpcftw_SetBarRequest,
        context: StatusOnlyCallContext
    ) -> EventLoopFuture<Grpcftw_SetBarResponse> {
        return context.eventLoop.makeCompletedFuture(.success(.init()))
    }

    func updateBar(
        request: Grpcftw_UpdateBarRequest,
        context: StatusOnlyCallContext
    ) -> EventLoopFuture<Grpcftw_UpdateBarResponse> {
        return context.eventLoop.makeCompletedFuture(.success(.init()))
    }

    func deleteBar(
        request: Grpcftw_DeleteBarRequest,
        context: StatusOnlyCallContext
    ) -> EventLoopFuture<Grpcftw_DeleteBarResponse> {
        return context.eventLoop.makeCompletedFuture(.success(.init()))
    }
}
