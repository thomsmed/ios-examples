//
//  AuthTokenProvider.swift
//  SharedAppAuthState
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import Foundation

protocol AuthTokenProvider: AnyObject {
    func performWithFreshToken(_ action: @escaping (Result<String, Error>) -> Void)
}
