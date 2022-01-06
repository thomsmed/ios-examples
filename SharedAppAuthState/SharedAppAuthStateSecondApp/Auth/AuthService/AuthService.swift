//
//  AuthService.swift
//  SharedAppAuthState
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import Foundation
import UIKit
import Combine

protocol AuthService: AnyObject {
    func login(_ completion: @escaping (Result<Void, Error>) -> Void)
    func logout()
    var hasSignedInBefore: Bool { get }
}


