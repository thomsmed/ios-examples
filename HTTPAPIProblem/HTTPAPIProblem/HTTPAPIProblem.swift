//
//  HTTPAPIProblem.swift
//  HTTPAPIProblem
//
//  Created by Thomas Smedmann on 07/01/2025.
//

import Foundation

// MARK: HTTP API Problem

/// Error thrown when decoding a`HTTPAPIProblem` if the decoded HTTP API Problem's type does not match the type of the associated `Extras`.
public struct HTTPAPIProblemTypeMismatch: Error {}

public protocol HTTPAPIProblemExtras: Decodable, Sendable {
    static var associatedProblemType: String? { get }
}

/// [RFC 7807 - Problem Details for HTTP APIs](https://www.rfc-editor.org/rfc/rfc7807).
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
}

extension HTTPAPIProblem: Decodable where Extras: Decodable {
    public init(from decoder: any Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let type = try keyedContainer.decode(String.self, forKey: .type)

        if let associatedProblemType = Extras.associatedProblemType {
            guard type == associatedProblemType else {
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

// MARK: Opaque/"untyped" HTTP API Problem

public struct OpaqueProblemExtras: HTTPAPIProblemExtras {
    public static let associatedProblemType: String? = nil
}

public typealias OpaqueHTTPAPIProblem = HTTPAPIProblem<OpaqueProblemExtras>

// MARK: Concrete HTTP API Problems (defined by Type and Extras)

public struct SomeExtras: HTTPAPIProblemExtras {
    public static let associatedProblemType: String? = "urn:some:problem:type"

    public let description: String
}
public typealias SomeHTTPAPIProblem = HTTPAPIProblem<SomeExtras>

public struct SomeOtherExtras: HTTPAPIProblemExtras {
    public static let associatedProblemType: String? = "https://my.domain.com/some-other-problem"

    public let message: String
}
public typealias SomeOtherHTTPAPIProblem = HTTPAPIProblem<SomeOtherExtras>

public struct UserActionRequiredExtras: HTTPAPIProblemExtras {
    public static let associatedProblemType: String? = "https://my.domain.com/action/required"

    public let description: String
    public let action: URL
}
public typealias UserActionRequiredHTTPAPIProblem = HTTPAPIProblem<UserActionRequiredExtras>

// MARK: Group/Collection of related HTTP API Problems (represented as an enum)

public enum CoreHTTPAPIProblem: Decodable, Error {
    case someProblem(SomeHTTPAPIProblem)
    case someOtherProblem(SomeOtherHTTPAPIProblem)
    case userActionRequired(UserActionRequiredHTTPAPIProblem)
    case opaqueProblem(OpaqueHTTPAPIProblem)

    public init(from decoder: any Decoder) throws {
        if let someProblem = try? SomeHTTPAPIProblem(from: decoder) {
            self = .someProblem(someProblem)
        } else if let someOtherProblem = try? SomeOtherHTTPAPIProblem(from: decoder) {
            self = .someOtherProblem(someOtherProblem)
        } else if let userActionRequired = try? UserActionRequiredHTTPAPIProblem(from: decoder) {
            self = .userActionRequired(userActionRequired)
        } else {
            // Fall back to an opaque/"untyped" HTTP API Problem
            self = .opaqueProblem(try OpaqueHTTPAPIProblem(from: decoder))
        }
    }
}
