//
//  SecureStorage.swift
//  KeychainStorage
//
//  Created by Thomas Asheim Smedmann on 26/09/2022.
//

import Foundation

enum SecureStorageError: Error {
    case invalidKey
    case invalidValue
    case notFound(description: String?)
    case typeMismatch
    case failedToPersist(description: String?)
    case failedToDelete(description: String?)
}

extension SecureStorageError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidKey:
            return "invalidKey"
        case .invalidValue:
            return "invalidValue"
        case .notFound(let description):
            if let description = description {
                return "notFound. Description: \(description)"
            }
            return "notFound"
        case .typeMismatch:
            return "typeMismatch"
        case .failedToPersist(let description):
            if let description = description {
                return "failedToPersist. Description: \(description)"
            }
            return "failedToPersist"
        case .failedToDelete(let description):
            if let description = description {
                return "failedToDelete. Description: \(description)"
            }
            return "failedToDelete"
        }
    }
}

protocol SecureStorage {
    func fetchObject<T>(for key: String) throws -> T where T: AnyObject
    func persistObject<T>(_ object: T, for key: String) throws where T: AnyObject
    func fetchValue<T>(for key: String) throws -> T where T: Decodable
    func persistValue<T>(_ value: T, for key: String) throws where T: Encodable
    func fetchString(for key: String) throws -> String
    func persistString(_ value: String, for key: String) throws
    func delete(for key: String) throws
}
