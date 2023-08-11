//
//  File.swift
//  
//
//  Created by Thomas Asheim Smedmann on 07/04/2024.
//

import Foundation
import CryptoKit

// MARK: P256

internal extension P256.Signing.PublicKey {
    var bitCount: Int { 256 }
}

internal extension P256.KeyAgreement.PublicKey {
    var bitCount: Int { 256 }
}

// MARK: P384

internal extension P384.Signing.PublicKey {
    var bitCount: Int { 384 }
}

internal extension P384.KeyAgreement.PublicKey {
    var bitCount: Int { 384 }
}

// MARK: P521

internal extension P521.Signing.PublicKey {
    var bitCount: Int { 521 }
}

internal extension P521.KeyAgreement.PublicKey {
    var bitCount: Int { 521 }
}
