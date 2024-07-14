//
//  OpaqueValue.swift
//  OpaqueValue
//
//  Created by Thomas Asheim Smedmann on 14/07/2024.
//

import Foundation

// MARK: OpaqueValue

/// An opaque Codable type that can represent arbitrary (Codable) data. E.g some arbitrary JSON.
/// It consists of one or more primitive types and/or one or more nested opaque values.
///
/// This code is heavily inspired [Rob Napier](https://stackoverflow.com/users/97337/rob-napier)'s answer to this [StackOverflow post](https://stackoverflow.com/questions/65901928/swift-jsonencoder-encoding-class-containing-a-nested-raw-json-object-literal).
enum OpaqueValue: Equatable {
    struct PropertyKey: CodingKey, Hashable {
        var stringValue: String
        var intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
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
