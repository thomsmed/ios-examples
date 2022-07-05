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

    func listBar(request: Grpcftw_ListBarRequest, context: StreamingResponseCallContext<Grpcftw_GetBarResponse>) -> EventLoopFuture<GRPCStatus> {
        context.sendResponse(.with({ _ in })).flatMap { _ in
            context.statusPromise.completeWith(.success(.ok))
        }
        return context.statusPromise.futureResult
    }

    func getBar(request: Grpcftw_GetBarRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Grpcftw_GetBarResponse> {
        context.statusPromise.completeWith(.success(.ok))
        return context.statusPromise.futureResult
    }

    func setBar(request: Grpcftw_SetBarRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Grpcftw_SetBarResponse> {
        context.statusPromise.completeWith(.success(.ok))
        return context.statusPromise.futureResult
    }

    func updateBar(request: Grpcftw_UpdateBarRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Grpcftw_UpdateBarResponse> {
        context.statusPromise.completeWith(.success(.ok))
        return context.statusPromise.futureResult
    }

    func deleteBar(request: Grpcftw_DeleteBarRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Grpcftw_DeleteBarResponse> {
        context.statusPromise.completeWith(.success(.ok))
        return context.statusPromise.futureResult
    }


}
