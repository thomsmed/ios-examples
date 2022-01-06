//
//  AuthError.swift
//  SharedAppAuthState
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import Foundation

enum AuthError: Error {
    case missingConfiguration
    case notAuthenticated
    case failedToPersistState
}
