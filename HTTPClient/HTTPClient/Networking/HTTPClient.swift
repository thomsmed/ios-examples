//
//  HTTPClient.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 02/09/2023.
//

import Foundation

/// A general purpose ``HTTPClient`` for doing network requests, with support for interceptors.
public protocol HTTPClient {
    /// GET resource at `url`.
    func get<ResponseBody: Decodable, ErrorBody: Decodable>(
        url: URL,
        responseType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws -> ResponseBody

    /// PUT `requestBody` of `requestType` on resource at `url`.
    func put<RequestBody: Encodable, ErrorBody: Decodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws

    /// PUT `requestBody` of `requestType` on resource at `url`, expecting `ResponseBody` of `responseType`.
    func put<RequestBody: Encodable, ResponseBody: Decodable, ErrorBody: Decodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        responseType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws -> ResponseBody

    /// POST `requestBody` of `requestType` to resource at `url`.
    func post<RequestBody: Encodable, ErrorBody: Decodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws

    /// POST `requestBody` of `requestType` to resource at `url`, expecting `ResponseBody` of `responseType`.
    func post<RequestBody: Encodable, ResponseBody: Decodable, ErrorBody: Decodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        responseType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws -> ResponseBody

    /// DELETE resource at `url`.
    func delete<ErrorBody: Decodable>(
        url: URL,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws -> Void
}

/// Convenience methods with empty array of interceptors, and default errorBodyType (as Data).
extension HTTPClient {
    public func get<ResponseBody: Decodable>(
        url: URL,
        responseType: HTTPMimeType
    ) async throws -> ResponseBody {
        try await get(
            url: url,
            responseType: responseType,
            interceptors: [],
            errorBodyType: Data.self
        )
    }

    public func put<RequestBody: Encodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType
    ) async throws {
        try await put(
            url: url,
            requestBody: requestBody,
            requestType: requestType,
            interceptors: [],
            errorBodyType: Data.self
        )
    }

    public func put<RequestBody: Encodable, ResponseBody: Decodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        responseType: HTTPMimeType
    ) async throws -> ResponseBody {
        try await put(
            url: url,
            requestBody: requestBody,
            requestType: requestType,
            responseType: responseType,
            interceptors: [],
            errorBodyType: Data.self
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
            interceptors: [],
            errorBodyType: Data.self
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
            interceptors: [],
            errorBodyType: Data.self
        )
    }

    public func delete(
        url: URL
    ) async throws -> Void {
        try await delete(
            url: url,
            interceptors: [],
            errorBodyType: Data.self
        )
    }
}
