//
//  HTTPClient.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 27/08/2023.
//

import Foundation

/// A default implementation of ``HTTPClient``.
public final class DefaultHTTPClient {
    /// And empty struct, representing an empty request body.
    private struct EmptyRequestBody: Encodable {}

    private let urlSession: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private let interceptors: [HTTPClientInterceptor]

    /// Initialise a new instance of ``HTTPClient``.
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

    private func encode<RequestBody: Encodable>(
        _ requestBody: RequestBody,
        contentType: HTTPMimeType
    ) throws -> Data {
        switch contentType {
            case .textHtml, .applicationJoseJson:
                // Plain text or a form of JWT (JWT, JWS or JWE).
                if let data = requestBody as? Data {
                    // Assume requestBody is already serialised as Data.
                    return data
                } else if let data = (requestBody as? String)?.data(using: .utf8) {
                    // Assume requestBody is already serialised as String. Convert to Data.
                    return data
                } else {
                    // Fallback to JSON encoding.
                    return try encoder.encode(requestBody)
                }
            case .applicationJson:
                return try encoder.encode(requestBody)
        }
    }

    private func makeErrorResponse<ErrorBody: Decodable>(
        statusCode: Int,
        data: Data
    ) -> HTTPClientError<ErrorBody>.ErrorResponse {
        // Try decode ErrorBody. If that fails, try casting data to ErrorBody (which will succeed if ErrorBody is of type Data).
        let errorBody = (try? decoder.decode(ErrorBody.self, from: data)) ?? data as? ErrorBody
        return HTTPClientError.ErrorResponse(statusCode: statusCode, errorBody: errorBody)
    }

    private func decode<ResponseBody: Decodable>(
        _ responseData: Data,
        accept: HTTPMimeType
    ) throws -> ResponseBody {
        switch accept {
            case .textHtml, .applicationJoseJson:
                // Plain text or a form of JWT (JWT, JWS or JWE).
                if let responseBody = responseData as? ResponseBody {
                    // Expected ResponseBody is Data.
                    return responseBody
                } else if
                    ResponseBody.self == String.self,
                    let responseBody = String(data: responseData, encoding: .utf8) as? ResponseBody
                {
                    // Expected ResponseBody is String.
                    return responseBody
                } else {
                    // Expected ResponseBody is Decodable.
                    return try decoder.decode(ResponseBody.self, from: responseData)
                }

            case .applicationJson:
                return try decoder.decode(ResponseBody.self, from: responseData)
        }
    }

    private func makeAndPrepareRequest<RequestBody: Encodable, ErrorBody: Decodable>(
        url: URL,
        httpMethod: HTTPMethod,
        requestBody: RequestBody,
        contentType: HTTPMimeType?,
        accept: HTTPMimeType?,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws -> URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = httpMethod.rawValue

        if let accept {
            request.setValue(accept.rawValue, forHTTPHeaderField: "Accept")
        }

        if let contentType {
            request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")

            do {
                request.httpBody = try encode(requestBody, contentType: contentType)
            } catch {
                throw HTTPClientError<ErrorBody>.encodingError(error)
            }
        }

        for interceptor in interceptors {
            try await interceptor.prepare(&request, with: HTTPClientContext(
                urlSession: urlSession,
                encoder: encoder,
                decoder: decoder
            ))
        }

        return request
    }

    private func fetchAndProcessResponse<ErrorBody: Decodable>(
        _ request: URLRequest,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws -> (Data, HTTPURLResponse) {
        var (data, response): (Data, URLResponse)
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            for interceptor in interceptors {
                await interceptor.handle(request, error: error)
            }

            throw HTTPClientError<ErrorBody>.transportError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("This type cast should never ever fail")
        }

        // Let the last interceptor process the response first.
        for interceptor in interceptors.reversed() {
            try await interceptor.process(httpResponse, data: &data, with: HTTPClientContext(
                urlSession: urlSession,
                encoder: encoder,
                decoder: decoder
            ))
        }

        return (data, httpResponse)
    }

    private func send<RequestBody: Encodable, ResponseBody: Decodable, ErrorBody: Decodable>(
        url: URL,
        httpMethod: HTTPMethod,
        requestBody: RequestBody,
        contentType: HTTPMimeType,
        accept: HTTPMimeType,
        interceptors perRequestInterceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws -> ResponseBody {
        let interceptors = interceptors + perRequestInterceptors

        let request = try await makeAndPrepareRequest(
            url: url,
            httpMethod: httpMethod,
            requestBody: requestBody,
            contentType: contentType,
            accept: accept,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )

        let (data, httpResponse) = try await fetchAndProcessResponse(
            request,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )

        switch httpResponse.statusCode {
            case 200..<300:
                do {
                    return try decode(data, accept: accept)
                } catch {
                    throw HTTPClientError<ErrorBody>.decodingError(error)
                }

            case 300..<400:
                do {
                    return try decode(data, accept: accept)
                } catch {
                    throw HTTPClientError<ErrorBody>.decodingError(error)
                }

            case 400..<500:
                throw HTTPClientError<ErrorBody>.clientError(makeErrorResponse(statusCode: httpResponse.statusCode, data: data))

            case 500..<600:
                throw HTTPClientError<ErrorBody>.serverError(makeErrorResponse(statusCode: httpResponse.statusCode, data: data))

            default:
                throw HTTPClientError<ErrorBody>.unexpectedStatusCode(httpResponse.statusCode)
        }
    }

    private func send<RequestBody: Encodable, ErrorBody: Decodable>(
        url: URL,
        httpMethod: HTTPMethod,
        requestBody: RequestBody,
        contentType: HTTPMimeType,
        interceptors perRequestInterceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws {
        let interceptors = interceptors + perRequestInterceptors

        let request = try await makeAndPrepareRequest(
            url: url,
            httpMethod: httpMethod,
            requestBody: requestBody,
            contentType: contentType,
            accept: nil,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )

        let (data, httpResponse) = try await fetchAndProcessResponse(
            request,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )

        switch httpResponse.statusCode {
            case 200..<300:
                return

            case 300..<400:
                return

            case 400..<500:
                throw HTTPClientError<ErrorBody>.clientError(makeErrorResponse(statusCode: httpResponse.statusCode, data: data))

            case 500..<600:
                throw HTTPClientError<ErrorBody>.serverError(makeErrorResponse(statusCode: httpResponse.statusCode, data: data))

            default:
                throw HTTPClientError<ErrorBody>.unexpectedStatusCode(httpResponse.statusCode)
        }
    }

    private func send<ResponseBody: Decodable, ErrorBody: Decodable>(
        url: URL,
        httpMethod: HTTPMethod,
        accept: HTTPMimeType,
        interceptors perRequestInterceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws -> ResponseBody {
        let interceptors = interceptors + perRequestInterceptors

        let request = try await makeAndPrepareRequest(
            url: url,
            httpMethod: httpMethod,
            requestBody: EmptyRequestBody(),
            contentType: nil,
            accept: accept,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )

        let (data, httpResponse) = try await fetchAndProcessResponse(
            request,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )

        switch httpResponse.statusCode {
            case 200..<300:
                do {
                    return try decode(data, accept: accept)
                } catch {
                    throw HTTPClientError<ErrorBody>.decodingError(error)
                }

            case 300..<400:
                do {
                    return try decode(data, accept: accept)
                } catch {
                    throw HTTPClientError<ErrorBody>.decodingError(error)
                }

            case 400..<500:
                throw HTTPClientError<ErrorBody>.clientError(makeErrorResponse(statusCode: httpResponse.statusCode, data: data))

            case 500..<600:
                throw HTTPClientError<ErrorBody>.serverError(makeErrorResponse(statusCode: httpResponse.statusCode, data: data))

            default:
                throw HTTPClientError<ErrorBody>.unexpectedStatusCode(httpResponse.statusCode)
        }
    }

    private func send<ErrorBody: Decodable>(
        url: URL,
        httpMethod: HTTPMethod,
        interceptors perRequestInterceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws {
        let interceptors = interceptors + perRequestInterceptors

        let request = try await makeAndPrepareRequest(
            url: url,
            httpMethod: httpMethod,
            requestBody: EmptyRequestBody(),
            contentType: nil,
            accept: nil,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )

        let (data, httpResponse) = try await fetchAndProcessResponse(
            request,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )

        switch httpResponse.statusCode {
            case 200..<300:
                return

            case 300..<400:
                return

            case 400..<500:
                throw HTTPClientError<ErrorBody>.clientError(makeErrorResponse(statusCode: httpResponse.statusCode, data: data))

            case 500..<600:
                throw HTTPClientError<ErrorBody>.serverError(makeErrorResponse(statusCode: httpResponse.statusCode, data: data))

            default:
                throw HTTPClientError<ErrorBody>.unexpectedStatusCode(httpResponse.statusCode)
        }
    }
}

extension DefaultHTTPClient: HTTPClient {
    public func get<ResponseBody: Decodable, ErrorBody: Decodable>(
        url: URL,
        responseType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws -> ResponseBody {
        try await send(
            url: url,
            httpMethod: .get,
            accept: responseType,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )
    }

    public func put<RequestBody: Encodable, ErrorBody: Decodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws {
        try await send(
            url: url,
            httpMethod: .put,
            requestBody: requestBody,
            contentType: requestType,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )
    }

    public func put<RequestBody: Encodable, ResponseBody: Decodable, ErrorBody: Decodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        responseType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws -> ResponseBody {
        try await send(
            url: url,
            httpMethod: .put,
            requestBody: requestBody,
            contentType: requestType,
            accept: requestType,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )
    }

    public func post<RequestBody: Encodable, ErrorBody: Decodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws {
        try await send(
            url: url,
            httpMethod: .post,
            requestBody: requestBody,
            contentType: requestType,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )
    }

    public func post<RequestBody: Encodable, ResponseBody: Decodable, ErrorBody: Decodable>(
        url: URL,
        requestBody: RequestBody,
        requestType: HTTPMimeType,
        responseType: HTTPMimeType,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws -> ResponseBody {
        try await send(
            url: url,
            httpMethod: .post,
            requestBody: requestBody,
            contentType: requestType,
            accept: requestType,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )
    }

    public func delete<ErrorBody: Decodable>(
        url: URL,
        interceptors: [HTTPClientInterceptor],
        errorBodyType: ErrorBody.Type
    ) async throws -> Void {
        try await send(
            url: url,
            httpMethod: .delete,
            interceptors: interceptors,
            errorBodyType: errorBodyType
        )
    }
}
