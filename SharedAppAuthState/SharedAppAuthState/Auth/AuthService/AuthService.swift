//
//  AuthService.swift
//  SharedAppAuthState
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import Foundation
import UIKit
import Combine

enum AuthServiceState {
    case unauthenticated
    case authenticated
    case needReathentication
}

protocol AuthService: AnyObject {
    func login(_ completion: @escaping (Result<Void, Error>) -> Void)
    func logout()
    var hasSignedInBefore: Bool { get }
    var state: AnyPublisher<AuthServiceState, Never> { get }
}


