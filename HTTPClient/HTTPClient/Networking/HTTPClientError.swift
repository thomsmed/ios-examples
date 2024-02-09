//
//  HTTPClientError.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 09/02/2024.
//

import Foundation

/// Enumeration describing errors that might occur in ``HTTPClient``.
///
/// The enumeration is generic over a `ErrorBody` type possibly returned from the server together with a HTTP Status 4xx or 5xx response.
public enum HTTPClientError<ErrorBody: Decodable>: Error {
    public struct ErrorResponse {
        public let statusCode: Int
        public let errorBody: ErrorBody?

        public init(statusCode: Int, errorBody: ErrorBody?) {
            self.statusCode = statusCode
            self.errorBody = errorBody
        }
    }

    case transportError(Error)
    case encodingError(Error)
    case decodingError(Error)
    case clientError(ErrorResponse)
    case serverError(ErrorResponse)
    case unexpectedStatusCode(Int)
}
