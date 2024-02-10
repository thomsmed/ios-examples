//
//  PrintHTTPClientInterceptor.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 10/02/2024.
//

import Foundation

struct PrintHTTPClientInterceptor: HTTPClientInterceptor {
    func prepare(_ request: inout URLRequest, with context: HTTPClientContext) async throws {
        print(">>> Request:", request.curlRepresentation)
    }

    func handle(_ request: URLRequest, error: Error) async {
        print("<<< Error:", error)
    }

    func process(_ response: HTTPURLResponse, data: inout Data, with context: HTTPClientContext) async throws {
        print("""
        <<< Response: \(response.url?.absoluteString ?? "<url>"), status = \(response.statusCode) \((200..<300 ~= response.statusCode ? "✅" : "⚠️"))
            headers = \(response.allHeaderFields.map { key, value in "\(key): \(value)" })
            body = \(String(data: data, encoding: .utf8).flatMap { $0.replacingOccurrences(of: "\n", with: " ") } ?? "<body>")
        """)
    }
}
