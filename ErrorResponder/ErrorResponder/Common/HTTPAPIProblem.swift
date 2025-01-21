//
//  HTTPAPIProblem.swift
//  ErrorResponder
//
//  Created by Thomas Smedmann on 21/01/2025.
//

//
// Stolen from [Handling HTTP API Errors with Problem Details](https://medium.com/@thomsmed/handling-http-api-errors-with-problem-details-398a9967aee4).
//

import Foundation

// MARK: HTTP API Problem

/// Error thrown when decoding a `HTTPAPIProblem` if the decoded HTTP API Problem's type does not match the type of the associated `Extras`.
public struct HTTPAPIProblemTypeMismatch: Error {}

/// Error thrown when decoding a `HTTPAPIProblem` if the decoded HTTP API Problem's type is empty/not present. A `HTTPAPIProblem` must always have a type.
public struct HTTPAPIProblemTypeMissing: Error {}

public protocol HTTPAPIProblemExtras: Decodable, Sendable {
    static var associatedProblemType: String? { get }
}

/// [RFC 9457 - Problem Details for HTTP APIs](https://datatracker.ietf.org/doc/rfc9457/).
public struct HTTPAPIProblem<Extras: HTTPAPIProblemExtras>: Error {
    public let type: String
    public let title: String
    public let status: Int
    public let detail: String
    public let instance: String
    public let extras: Extras

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case status
        case detail
        case instance
    }

    public init(type: String, title: String, status: Int, detail: String, instance: String, extras: Extras) throws {
        if type.isEmpty {
            throw HTTPAPIProblemTypeMissing()
        }

        if let associatedProblemType = Extras.associatedProblemType {
            if type != associatedProblemType {
                throw HTTPAPIProblemTypeMismatch()
            }
        }

        self.type = type
        self.title = title
        self.status = status
        self.detail = detail
        self.instance = instance
        self.extras = extras
    }

    public init(title: String, status: Int, detail: String, instance: String, extras: Extras) throws {
        guard let type = Extras.associatedProblemType, !type.isEmpty else {
            throw HTTPAPIProblemTypeMissing()
        }

        self.type = type
        self.title = title
        self.status = status
        self.detail = detail
        self.instance = instance
        self.extras = extras
    }
}

extension HTTPAPIProblem: Decodable where Extras: Decodable {
    public init(from decoder: any Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let type = try keyedContainer.decode(String.self, forKey: .type)

        if type.isEmpty {
            throw HTTPAPIProblemTypeMissing()
        }

        if let associatedProblemType = Extras.associatedProblemType {
            if type != associatedProblemType {
                throw HTTPAPIProblemTypeMismatch()
            }
        }

        self.type = type
        self.title = try keyedContainer.decode(String.self, forKey: .title)
        self.status = try keyedContainer.decode(Int.self, forKey: .status)
        self.detail = try keyedContainer.decode(String.self, forKey: .detail)
        self.instance = try keyedContainer.decode(String.self, forKey: .instance)

        self.extras = try Extras(from: decoder)
    }
}
