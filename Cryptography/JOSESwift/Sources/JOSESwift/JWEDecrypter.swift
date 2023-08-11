//
//  JWEDecrypter.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 28/03/2024.
//

import Foundation
import CryptoKit

public protocol JWEDecrypter {
    func decrypt<Payload: Codable>(_ jwe: JWE<Payload>) throws -> Payload
}

// MARK: ECDHESA256GCMDecrypter

public struct ECDHESA256GCMDecrypter: JWEDecrypter {
    public func decrypt<Payload: Codable>(_ jwe: JWE<Payload>) throws -> Payload {
        fatalError()
    }
}
