//
//  FooServiceClientInterceptorFactory.swift
//  GRPCFTWClient
//
//  Created by Thomas Asheim Smedmann on 25/06/2022.
//

import GRPC

final class FooServiceClientInterceptorFactory: Grpcftw_FooServiceClientInterceptorFactoryProtocol {

    func makeListFooInterceptors() -> [ClientInterceptor<Grpcftw_ListFooRequest, Grpcftw_GetFooResponse>] {
        [LoggingInterceptor()]
    }

    func makeGetFooInterceptors() -> [ClientInterceptor<Grpcftw_GetFooRequest, Grpcftw_GetFooResponse>] {
        [LoggingInterceptor()]
    }

    func makeSetFooInterceptors() -> [ClientInterceptor<Grpcftw_SetFooRequest, Grpcftw_SetFooResponse>] {
        [LoggingInterceptor()]
    }

    func makeUpdateFooInterceptors() -> [ClientInterceptor<Grpcftw_UpdateFooRequest, Grpcftw_UpdateFooResponse>] {
        [LoggingInterceptor()]
    }

    func makeDeleteFooInterceptors() -> [ClientInterceptor<Grpcftw_DeleteFooRequest, Grpcftw_DeleteFooResponse>] {
        [LoggingInterceptor()]
    }
}
