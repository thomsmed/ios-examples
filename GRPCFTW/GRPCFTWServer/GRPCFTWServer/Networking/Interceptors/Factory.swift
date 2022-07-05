//
//  Factory.swift
//  GRPCFTWServer
//
//  Created by Thomas Asheim Smedmann on 25/06/2022.
//

import NIO
import GRPC

final class Factory: Grpcftw_BarServiceServerInterceptorFactoryProtocol {

    func makeListBarInterceptors() -> [ServerInterceptor<Grpcftw_ListBarRequest, Grpcftw_GetBarResponse>] {
        []
    }

    func makeGetBarInterceptors() -> [ServerInterceptor<Grpcftw_GetBarRequest, Grpcftw_GetBarResponse>] {
        []
    }

    func makeSetBarInterceptors() -> [ServerInterceptor<Grpcftw_SetBarRequest, Grpcftw_SetBarResponse>] {
        []
    }

    func makeUpdateBarInterceptors() -> [ServerInterceptor<Grpcftw_UpdateBarRequest, Grpcftw_UpdateBarResponse>] {
        []
    }

    func makeDeleteBarInterceptors() -> [ServerInterceptor<Grpcftw_DeleteBarRequest, Grpcftw_DeleteBarResponse>] {
        []
    }
}
