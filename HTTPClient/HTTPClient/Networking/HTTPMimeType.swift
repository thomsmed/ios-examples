//
//  HTTPMimeType.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 09/02/2024.
//

import Foundation

/// Enumeration representing possible HTTP MIME (Multipurpose Internet Mail Extensions) Types.
public enum HTTPMimeType: String {
    case textHtml = "text/html; charset=utf-8"
    case applicationJson = "application/json; charset=utf-8"
    case applicationJoseJson = "application/jose+json; charset=utf-8"
}
