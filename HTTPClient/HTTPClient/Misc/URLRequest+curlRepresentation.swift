//
//  URLRequest+curlRepresentation.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 10/02/2024.
//

import Foundation

public extension URLRequest {
    var curlRepresentation: String {
        guard let url = url?.absoluteString else {
            return "could not create curl command"
        }

        var components = ["curl \(url)"]

        if let method = httpMethod, method != "GET" {
            components.append("-X \(method)")
        }

        for (key, value) in allHTTPHeaderFields ?? [:] {
            components.append("-H '\(key): \(value)'")
        }

        if let body = httpBody, let bodyString = String(data: body, encoding: .utf8) {
            let sanitizedBody = bodyString
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "'", with: "\\'")

            components.append("-d '\(sanitizedBody)'")
        }

        return components.joined(separator: "\n\t")
    }
}
