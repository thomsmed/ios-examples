//
//  WidgetAuthTokenProvider.swift
//  SharedAppAuthStateWidgetExtension
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import Foundation

final class WidgetAuthTokenProvider: AuthTokenProvider {
    private let authStateRepository: AuthStateRepository
    
    init(authStateRepository: AuthStateRepository) {
        self.authStateRepository = authStateRepository
    }
    
    func performWithFreshToken(_ action: @escaping (Result<String, Error>) -> Void) {
        guard let authState = authStateRepository.state else {
            return action(.failure(AuthError.notAuthenticated))
        }
        
        authState.performAction { accessToken, idToken, error in
            if let error = error {
                return action(.failure(error))
            }
            
            guard let accessToken = accessToken else {
                return action(.failure(AuthError.notAuthenticated))
            }
            
            action(.success(accessToken))
        }
    }
}
