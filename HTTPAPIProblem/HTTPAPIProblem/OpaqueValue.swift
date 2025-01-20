//
//  OpaqueValue.swift
//  HTTPAPIProblem
//
//  Created by Thomas Smedmann on 20/01/2025.
//

import Foundation

// MARK: OpaqueValue

/// Stolen from [Representing arbitrary data (e.g JSON) as a custom and opaque Codable type](https://medium.com/@thomsmed/representing-arbitrary-data-e-g-json-as-a-custom-and-opaque-codable-type-dfaa07b22cd3).
enum OpaqueValue: Equatable, Sendable {
    struct PropertyKey: CodingKey, Hashable {
        var stringValue: String
        var intValue: Int?

        init(stringValue: String) {
            self.stringValue = stringValue
        }

        init(intValue: Int) {
            self.intValue = intValue
            self.stringValue = String(intValue)
        }
    }

    case object([PropertyKey: OpaqueValue])
    case array([OpaqueValue])
    case string(String)
    case number(Double)
    case boolean(Bool)
    case null
}

// MARK: OpaqueValue+Encodable

extension OpaqueValue: Encodable {
    func encode(to encoder: any Encoder) throws {
        switch self {
        case .object(let values):
            var container = encoder.container(keyedBy: PropertyKey.self)
            for (key, value) in values {
                try container.encode(value, forKey: key)
            }
        case .array(let values):
            var container = encoder.unkeyedContainer()
            for value in values {
                try container.encode(value)
            }
        case .string(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .number(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .boolean(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
}

// MARK: OpaqueValue+Decodable

extension OpaqueValue: Decodable {
    init(from decoder: any Decoder) throws {
        if let container = try? decoder.container(keyedBy: PropertyKey.self) {
            var values: [PropertyKey: OpaqueValue] = [:]
            for key in container.allKeys {
                values[key] = try container.decode(OpaqueValue.self, forKey: key)
            }
            self = .object(values)
        } else if var container = try? decoder.unkeyedContainer() {
            var values: [OpaqueValue] = []
            while !container.isAtEnd {
                values.append(try container.decode(OpaqueValue.self))
            }
            self = .array(values)
        } else {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(String.self) {
                self = .string(value)
            } else if let value = try? container.decode(Double.self) {
                self = .number(value)
            } else if let value = try? container.decode(Bool.self) {
                self = .boolean(value)
            } else {
                guard container.decodeNil() else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Data unrecognizable")
                }
                self = .null
            }
        }
    }
}
