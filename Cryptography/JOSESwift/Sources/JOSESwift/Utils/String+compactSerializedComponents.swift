//
//  String+compactSerializedComponents.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 28/03/2024.
//

import Foundation

internal extension String {
    var compactSerializedComponents: [String] {
        split(separator: ".", maxSplits: 5, omittingEmptySubsequences: false).map { String($0) }
    }
}
