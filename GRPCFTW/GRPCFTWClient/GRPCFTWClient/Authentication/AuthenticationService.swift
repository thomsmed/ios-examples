//
//  AuthenticationService.swift
//  GRPCFTWClient
//
//  Created by Thomas Asheim Smedmann on 25/06/2022.
//

import NIOCore

protocol AuthenticationService: AnyObject {
    var currentAuthToken: String? { get }
//    var authToken: EventLoopFuture<String> { get }
}

final class DefaultAuthenticationService {

    init() {
        // Initialize the AuthenticationService
    }
}

// MARK: AuthenticationService

extension DefaultAuthenticationService: AuthenticationService {

    var currentAuthToken: String? {
        "<some-auth-token>"
    }

//    var authToken: EventLoopFuture<String> {
//
//    }
}
