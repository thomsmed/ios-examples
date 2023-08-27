//
//  HTTPClient.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 02/09/2023.
//

import Foundation

/// Enumeration representing possible HTTP MIME (Multipurpose Internet Mail Extensions) Types.
public enum HTTPMimeType: String {
    case textHtml = "text/html"
    case applicationJson = "application/json"
    case applicationJoseJson = "application/jose+json"
}

/// A general purpose ``HTTPClient`` for doing network requests, and with support for interceptors.
public protocol HTTPClient {
    func get<ResponseBody: Decodable>(
        url: URL,
        responseType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor]
    ) async throws -> ResponseBody

    func post<RequestBody: Encodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor]
    ) async throws

    func post<RequestBody: Encodable, ResponseBody: Decodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        responseType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor]
    ) async throws -> ResponseBody
}

/// Convenience methods with empty array of interceptors.
extension HTTPClient {
    public func get<ResponseBody: Decodable>(
        url: URL,
        responseType: HTTPMimeType
    ) async throws -> ResponseBody {
        try await get(
            url: url,
            responseType: responseType,
            interceptors: []
        )
    }

    public func post<RequestBody: Encodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType
    ) async throws {
        try await post(
            url: url,
            requestBody: requestBody,
            requestType: requestType,
            interceptors: []
        )
    }

    public func post<RequestBody: Encodable, ResponseBody: Decodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        responseType: HTTPMimeType
    ) async throws -> ResponseBody {
        try await post(
            url: url,
            requestBody: requestBody,
            requestType: requestType,
            responseType: responseType,
            interceptors: []
        )
    }
}
