//
//  Request+Endpoint.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 24/07/2022.
//

import Foundation

extension Request {

    enum Endpoint {
        case stores
        case store(id: Int)
    }
}

extension Request.Endpoint {

    var urlComponents: URLComponents {
        switch self {
        case .stores:
            return .init(string: "stores")!
        case let .store(id):
            return .init(string: "stores/\(id)")!
        }
    }
}
