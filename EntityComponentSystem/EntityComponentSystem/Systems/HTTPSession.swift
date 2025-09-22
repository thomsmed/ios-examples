//
//  HTTPSession.swift
//  EntityComponentSystem
//
//  Created by Thomas Smedmann on 22/09/2025.
//

import Foundation

protocol HTTPSession {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

struct Endpoint<Resource>: Sendable {

    struct Payload {
        let data: Data
    }

    struct Parser {
        let parse: @Sendable (Data, HTTPURLResponse) throws -> Resource
    }

    let url: URL
    let payload: Payload
    let parser: Parser
}

extension Endpoint.Payload {

    static var empty: Endpoint.Payload {
        Endpoint.Payload(data: Data())
    }
}

extension Endpoint.Parser where Resource: Decodable {

    static var json: Endpoint.Parser {
        Endpoint.Parser { data, _ in
            let decoder = JSONDecoder()
            return try decoder.decode(Resource.self, from: data)
        }
    }
}

extension Endpoint.Parser where Resource == Data {

    static var raw: Endpoint.Parser {
        Endpoint.Parser { data, _ in
            data
        }
    }
}

extension HTTPSession {

    func call<Resource>(_ endpoint: Endpoint<Resource>) async throws -> Resource {
        var request = URLRequest(url: endpoint.url)
        request.httpBody = endpoint.payload.data

        let (data, httpUrlResponse) = try await data(for: request)

        return try endpoint.parser.parse(data, httpUrlResponse)
    }
}

extension URLSession: HTTPSession {

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        try await self.data(for: request, delegate: nil) as! (Data, HTTPURLResponse)
    }
}
