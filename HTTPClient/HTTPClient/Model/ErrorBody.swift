//
//  ErrorBody.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 10/02/2024.
//

import Foundation

struct ErrorBody: Decodable {
    let title: String
    let message: String
}
