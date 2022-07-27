//
//  DefaultNetworkClient.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 24/07/2022.
//

import Foundation

final class DefaultNetworkClient {

    struct DefaultNetworkTask: NetworkTask {
        weak var urlSessionTask: URLSessionTask?

        func cancel() {
            urlSessionTask?.cancel()
        }
    }

    private let urlSession = URLSession.shared

    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }
}

extension DefaultNetworkClient: NetworkClient {

    func get<T>(
        at endpoint: Request.Endpoint,
        _ completion: @escaping (Result<T, NetworkClientError>) -> Void
    ) -> NetworkTask where T : Decodable {
        let request = RequestBuilder(endpoint: endpoint)
            .with(method: .get)
            .with(header: .accept(mime: .json))
            .makeRequest(baseURL: baseURL)

        let dataTask = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(.network(error)))
            }

            let httpURLResponse = response as! HTTPURLResponse

            guard httpURLResponse.statusCode == 200 else {
                return completion(.failure(.clientError(code: httpURLResponse.statusCode)))
            }

            guard
                let data = data,
                let value = try? self.jsonDecoder.decode(T.self, from: data)
            else {
                return completion(.failure(.decodingFailed))
            }

            completion(.success(value))
        }

        dataTask.resume()

        return DefaultNetworkTask(urlSessionTask: dataTask)
    }

    func post<T>(
        to endpoint: Request.Endpoint,
        _ value: T,
        _ completion: @escaping (Result<Void, NetworkClientError>) -> Void
    ) -> NetworkTask where T : Encodable {
        guard let data = try? jsonEncoder.encode(value) else {
            completion(.failure(.encodingFailed))

            return DefaultNetworkTask()
        }

        let request = RequestBuilder(endpoint: endpoint)
            .with(method: .post)
            .with(header: .authorization(token: "<auth-token>"))
            .with(data: data)
            .makeRequest(baseURL: baseURL)

        let dataTask = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(.network(error)))
            }

            let httpURLResponse = response as! HTTPURLResponse

            guard httpURLResponse.statusCode == 200 else {
                if httpURLResponse.statusCode == 401 {
                    return completion(.failure(.notAuthenticated))
                }
                return completion(.failure(.clientError(code: httpURLResponse.statusCode)))
            }

            completion(.success(()))
        }

        dataTask.resume()

        return DefaultNetworkTask(urlSessionTask: dataTask)
    }
}
