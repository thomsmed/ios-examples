//
//  Data+hex.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 18/03/2024.
//

import Foundation

extension Data {
    var hex: String {
        map { String(format: "%02X", $0) }.joined()
    }
}
