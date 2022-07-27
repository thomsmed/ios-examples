//
//  Request.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 24/07/2022.
//

import Foundation

enum Request {

    enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    enum Mime: String {
        case html = "text/html"
        case json = "application/json"
    }

    enum Header {
        case authorization(token: String)
        case accept(mime: Request.Mime)
    }
}
