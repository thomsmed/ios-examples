//
//  RequestBuilder.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 24/07/2022.
//

import Foundation

final class RequestBuilder {

    private var urlComponents: URLComponents
    private var urlRequest: URLRequest

    init(endpoint: Request.Endpoint) {
        urlComponents = endpoint.urlComponents
        urlRequest = .init(url: urlComponents.url!)
    }

    func makeRequest(baseURL: URL) -> URLRequest {
        urlRequest.url = urlComponents.url(relativeTo: baseURL) ?? baseURL
        return urlRequest
    }
}

extension RequestBuilder {

    func with(method: Request.Method) -> RequestBuilder {
        urlRequest.httpMethod = method.rawValue
        return self
    }

    func with(header: Request.Header) -> RequestBuilder {
        switch header {
        case let .authorization(token):
            urlRequest.addValue("Bearer: \(token)", forHTTPHeaderField: "Authorization")
        case let .accept(mime):
            urlRequest.addValue("Accept", forHTTPHeaderField: mime.rawValue)
        }
        return self
    }

    func with(data: Data) -> RequestBuilder {
        urlRequest.httpBody = data
        return self
    }
}
