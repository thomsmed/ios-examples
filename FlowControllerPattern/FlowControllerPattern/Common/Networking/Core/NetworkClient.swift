//
//  NetworkClient.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 24/07/2022.
//

import Foundation

protocol NetworkTask {
    func cancel()
}

enum NetworkClientError: Error {
    case decodingFailed
    case encodingFailed
    case notAuthenticated
    case network(Error)
    case clientError(code: Int)
    case serverError(code: Int)
}

protocol NetworkClient: AnyObject {
    func get<T>(
        at endpoint: Request.Endpoint,
        _ completion: @escaping (Result<T, NetworkClientError>) -> Void
    ) -> NetworkTask where T: Decodable
    func post<T>(
        to endpoint: Request.Endpoint,
        _ value: T,
        _ completion: @escaping (Result<Void, NetworkClientError>) -> Void
    ) -> NetworkTask where T: Encodable
}
