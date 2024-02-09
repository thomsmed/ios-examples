//
//  HTTPClientInterceptor.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 27/08/2023.
//

import Foundation

/// A context for interceptors to get a hold on the ``URLSession``, ``JSONEncoder`` and ``JSONDecoder`` the associated ``HTTPClient`` uses.
///
/// These properties can be used to decode/encode or do intermediate network request before/after outgoing network request.
public struct HTTPClientContext {
    let urlSession: URLSession
    let encoder: JSONEncoder
    let decoder: JSONDecoder
}

/// Protocol for implementing interceptors used by ``HTTPClient``.
///
/// The first interceptor passed to ``HTTPClient`` is the first to prepare outgoing request,
/// and the last to process incoming responses.
public protocol HTTPClientInterceptor {
    /// Prepare the outgoing ``URLRequest``.
    /// The first interceptor passed to ``HTTPClient`` will be the first to have a chance at manipulating the outgoing requests.
    func prepare(_ request: inout URLRequest, with context: HTTPClientContext) async throws

    /// Handle any error that might occur while the outgoing ``URLRequest`` is in flight.
    /// The first interceptor passed to ``HTTPClient`` will be the first to have a chance at reacting to the error.
    func handle(_ request: URLRequest, error: Error) async

    /// Process the incoming ``HTTPURLResponse``.
    /// The first interceptor passed to ``HTTPClient`` will be the last to have a chance at manipulating the incoming response data.
    /// And vice versa, the last interceptor will be the first to have a chance processing the incoming response data.
    func process(_ response: HTTPURLResponse, data: inout Data, with context: HTTPClientContext) async throws
}

/// Make methods non-required with default empty implementations.
extension HTTPClientInterceptor {
    public func prepare(_ request: inout URLRequest, with context: HTTPClientContext) async throws {}
    public func handle(_ request: URLRequest, error: Error) async {}
    public func process(_ response: HTTPURLResponse, data: inout Data, with context: HTTPClientContext) async throws {}
}
