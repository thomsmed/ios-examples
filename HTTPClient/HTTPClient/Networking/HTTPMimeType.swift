//
//  HTTPMimeType.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 09/02/2024.
//

import Foundation

/// Enumeration representing possible HTTP MIME (Multipurpose Internet Mail Extensions) Types.
public enum HTTPMimeType: String {
    case textHtml = "text/html"
    case applicationJson = "application/json"
    case applicationJoseJson = "application/jose+json"
}
