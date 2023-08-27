//
//  HTTPClient.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 27/08/2023.
//

import Foundation

/// Enumeration representing possible HTTP Request Methods.
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// Enumeration describing errors that might occur in ``HTTPClient``.
public enum HTTPClientError: Error {
    case failedToEncodeRequest
    case failedToDecodeResponse
    case clientError(Int)
    case serverError(Int)
    case unexpectedStatusCode(Int)
}

/// A default implementation of ``HTTPClient``.
public class DefaultHTTPClient {
    private static let defaultTimeout: TimeInterval = 15

    let urlSession: URLSession
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    let interceptors: [HTTPClientInterceptor]

    /// Initialize a new instance of ``HTTPClient``.
    ///
    /// - Parameters:
    ///   - urlSession: URLSession used for network requests.
    ///   - encoder: JSONEncoder used to encode request bodies.
    ///   - decoder: JSONDecoder used to decode response bodies.
    ///   - interceptors: An array of ``HTTPClientInterceptor``. The order matter, as the first ``HTTPClientInterceptor`` is the first to prepare outgoing requests, and the last to process incoming responses.
    public init(
        urlSession: URLSession = URLSession.shared,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder(),
        interceptors: [HTTPClientInterceptor] = []
    ) {
        self.urlSession = urlSession
        self.encoder = encoder
        self.decoder = decoder
        self.interceptors = interceptors
    }

    private func send<RequestBody: Encodable>(
        url: URL,
        httpMethod: HTTPMethod,
        requestBody: RequestBody,
        contentType: HTTPMimeType,
        timeout timeoutInterval: TimeInterval,
        perRequestInterceptors: [HTTPClientInterceptor]
    ) async throws {
        var request = URLRequest(url: url)

        request.httpMethod = httpMethod.rawValue

        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")

        request.timeoutInterval = timeoutInterval

        request.httpBody = try encoder.encode(requestBody)

        for interceptor in interceptors {
            try await interceptor.prepare(
                &request,
                with: .init(
                    urlSession: urlSession,
                    encoder: encoder,
                    decoder: decoder
                )
            )
        }

        // Per-request interceptors prepare the request last.
        for interceptor in perRequestInterceptors {
            try await interceptor.prepare(
                &request,
                with: .init(
                    urlSession: urlSession,
                    encoder: encoder,
                    decoder: decoder
                )
            )
        }

        var (data, response): (Data, URLResponse)
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            for interceptor in interceptors {
                await interceptor.handle(request, error: error)
            }

            for interceptor in perRequestInterceptors {
                await interceptor.handle(request, error: error)
            }

            // Re-throw the error
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.failedToEncodeRequest
        }

        // Let the last per-request interceptor process the response first.
        for interceptor in perRequestInterceptors.reversed() {
            try await interceptor.process(
                httpResponse,
                data: &data,
                with: .init(
                    urlSession: urlSession,
                    encoder: encoder,
                    decoder: decoder
                )
            )
        }

        // Let the last interceptor process the response first.
        for interceptor in interceptors.reversed() {
            try await interceptor.process(
                httpResponse,
                data: &data,
                with: .init(
                    urlSession: urlSession,
                    encoder: encoder,
                    decoder: decoder
                )
            )
        }

        switch httpResponse.statusCode {
            case 200..<300:
                return

            case 300..<400:
                // Handle 3xx in a different way?
                return

            case 400..<500:
                throw HTTPClientError.clientError(httpResponse.statusCode)

            case 500..<600:
                throw HTTPClientError.serverError(httpResponse.statusCode)

            default:
                throw HTTPClientError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }

    private func send<ResponseBody: Decodable>(
        url: URL,
        httpMethod: HTTPMethod,
        accept: HTTPMimeType,
        timeout timeoutInterval: TimeInterval,
        perRequestInterceptors: [HTTPClientInterceptor]
    ) async throws -> ResponseBody {
        var request = URLRequest(url: url)

        request.httpMethod = httpMethod.rawValue

        request.setValue(accept.rawValue, forHTTPHeaderField: "Accept")

        request.timeoutInterval = timeoutInterval

        for interceptor in interceptors {
            try await interceptor.prepare(
                &request,
                with: .init(
                    urlSession: urlSession,
                    encoder: encoder,
                    decoder: decoder
                )
            )
        }

        // Per-request interceptors prepare the request last.
        for interceptor in perRequestInterceptors {
            try await interceptor.prepare(
                &request,
                with: .init(
                    urlSession: urlSession,
                    encoder: encoder,
                    decoder: decoder
                )
            )
        }

        var (data, response): (Data, URLResponse)
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            for interceptor in interceptors {
                await interceptor.handle(request, error: error)
            }

            for interceptor in perRequestInterceptors {
                await interceptor.handle(request, error: error)
            }

            // Re-throw the error
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.failedToEncodeRequest
        }

        // Let the last per-request interceptor process the response first.
        for interceptor in perRequestInterceptors.reversed() {
            try await interceptor.process(
                httpResponse,
                data: &data,
                with: .init(
                    urlSession: urlSession,
                    encoder: encoder,
                    decoder: decoder
                )
            )
        }

        // Let the last interceptor process the response first.
        for interceptor in interceptors.reversed() {
            try await interceptor.process(
                httpResponse,
                data: &data,
                with: .init(
                    urlSession: urlSession,
                    encoder: encoder,
                    decoder: decoder
                )
            )
        }

        switch httpResponse.statusCode {
            case 200..<300:
                return try decoder.decode(ResponseBody.self, from: data)

            case 300..<400:
                // Handle 3xx in a different way?
                return try decoder.decode(ResponseBody.self, from: data)

            case 400..<500:
                throw HTTPClientError.clientError(httpResponse.statusCode)

            case 500..<600:
                throw HTTPClientError.serverError(httpResponse.statusCode)

            default:
                throw HTTPClientError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }

    private func send<RequestBody: Encodable, ResponseBody: Decodable>(
        url: URL,
        httpMethod: HTTPMethod,
        requestBody: RequestBody,
        contentType: HTTPMimeType,
        accept: HTTPMimeType,
        timeout timeoutInterval: TimeInterval,
        perRequestInterceptors: [HTTPClientInterceptor]
    ) async throws -> ResponseBody {
        var request = URLRequest(url: url)

        request.httpMethod = httpMethod.rawValue

        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.setValue(accept.rawValue, forHTTPHeaderField: "Accept")

        request.timeoutInterval = timeoutInterval

        request.httpBody = try encoder.encode(requestBody)

        for interceptor in interceptors {
            try await interceptor.prepare(
                &request,
                with: .init(
                    urlSession: urlSession,
                    encoder: encoder,
                    decoder: decoder
                )
            )
        }

        // Per-request interceptors prepare the request last.
        for interceptor in perRequestInterceptors {
            try await interceptor.prepare(
                &request,
                with: .init(
                    urlSession: urlSession,
                    encoder: encoder,
                    decoder: decoder
                )
            )
        }

        var (data, response): (Data, URLResponse)
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            for interceptor in interceptors {
                await interceptor.handle(request, error: error)
            }

            for interceptor in perRequestInterceptors {
                await interceptor.handle(request, error: error)
            }

            // Re-throw the error
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.failedToEncodeRequest
        }

        // Let the last per-request interceptor process the response first.
        for interceptor in perRequestInterceptors.reversed() {
            try await interceptor.process(
                httpResponse,
                data: &data,
                with: .init(
                    urlSession: urlSession,
                    encoder: encoder,
                    decoder: decoder
                )
            )
        }

        // Let the last interceptor process the response first.
        for interceptor in interceptors.reversed() {
            try await interceptor.process(
                httpResponse,
                data: &data,
                with: .init(
                    urlSession: urlSession,
                    encoder: encoder,
                    decoder: decoder
                )
            )
        }

        switch httpResponse.statusCode {
            case 200..<300:
                return try decoder.decode(ResponseBody.self, from: data)

            case 300..<400:
                // Handle 3xx in a different way?
                return try decoder.decode(ResponseBody.self, from: data)

            case 400..<500:
                throw HTTPClientError.clientError(httpResponse.statusCode)

            case 500..<600:
                throw HTTPClientError.serverError(httpResponse.statusCode)

            default:
                throw HTTPClientError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }
}

extension DefaultHTTPClient: HTTPClient {
    public func get<ResponseBody: Decodable>(
        url: URL,
        responseType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor]
    ) async throws -> ResponseBody {
        try await send(
            url: url,
            httpMethod: .get,
            accept: responseType,
            timeout: Self.defaultTimeout,
            perRequestInterceptors: interceptors
        )
    }

    public func post<RequestBody: Encodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor]
    ) async throws {
        try await send(
            url: url,
            httpMethod: .post,
            requestBody: requestBody,
            contentType: requestType,
            timeout: Self.defaultTimeout,
            perRequestInterceptors: interceptors
        )
    }

    public func post<RequestBody: Encodable, ResponseBody: Decodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        responseType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor]
    ) async throws -> ResponseBody {
        try await send(
            url: url,
            httpMethod: .post,
            requestBody: requestBody,
            contentType: requestType,
            accept: responseType,
            timeout: Self.defaultTimeout,
            perRequestInterceptors: interceptors
        )
    }
}
