//
//  Auth0AuthService.swift
//  SharedAppAuthState
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import Foundation
import AppAuth

struct Auth0Configuration {
    let openIdDomain: String
    let openIdClientId: String
    let issuer: URL
    let callbackUrl: URL
}

final class Auth0AuthService: AuthService {
    private let configuration: Auth0Configuration
    private let authStateRepository: AuthStateRepository
    
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    init(configuration: Auth0Configuration, authStateRepository: AuthStateRepository) {
        self.configuration = configuration
        self.authStateRepository = authStateRepository
    }
    
    var hasSignedInBefore: Bool {
        authStateRepository.state != nil
    }
    
    private func discoverAndCreateRequest(then completion: @escaping (Result<OIDAuthorizationRequest, Error>) -> Void) {
        OIDAuthorizationService.discoverConfiguration(forIssuer: configuration.issuer) { configuration, error in
            if let error = error {
                return completion(.failure(error))
            }
            
            guard let configuration = configuration else {
                return completion(.failure(AuthError.missingConfiguration))
            }
            
            let scopes = [
                OIDScopeOpenID,
                OIDScopeProfile,
                // Auth0 scopes
                "offline_access", // Refresh token
                // Custom scopes
                "write:items",
                "read:items"
            ]
            
            // Additional parameter (specific for Auth0 etc)
            let additionalParameters = [
                "audience": "https://api.thomsmed.com"
            ]
            
            // builds authentication request (initialiser generates a state parameter and PKCE challenges automatically)
            let request = OIDAuthorizationRequest(configuration: configuration,
                                                  clientId: self.configuration.openIdClientId,
                                                  clientSecret: nil,
                                                  scopes: scopes,
                                                  redirectURL: self.configuration.callbackUrl,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: additionalParameters)
            
            completion(.success(request))
        }
    }
    
    private func createEndedFlowCallback(with completion: @escaping (Result<Void, Error>) -> Void) -> (OIDAuthState?, Error?) -> Void {
        return { authState, error in
            if let error = error {
                return completion(.failure(error))
            }
            
            guard let authState = authState else {
                return completion(.failure(AuthError.notAuthenticated))
            }
            
            do {
                try self.authStateRepository.persist(state: authState)
            } catch {
                return completion(.failure(error))
            }
            
            completion(.success(()))
        }
    }
    
    func login(_ completion: @escaping (Result<Void, Error>) -> Void) {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootViewController = windowScene.windows.first?.rootViewController
        else {
            fatalError()
        }
        
        discoverAndCreateRequest(then: { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let request):
                self.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request,
                                                                       presenting: rootViewController,
                                                                       callback: self.createEndedFlowCallback(with: completion))
            }
        })
    }
    
    func logout() {
        authStateRepository.clear()
    }
}

extension Auth0AuthService: AuthTokenProvider {
    func performWithFreshToken(_ action: @escaping (Result<String, Error>) -> Void) {
        guard let authState = authStateRepository.state else {
            return action(.failure(AuthError.notAuthenticated))
        }
        
        authState.performAction { (accessToken, idToken, error) in
            if let error = error {
                let nsError = error as NSError
                let oidErrorCode = OIDErrorCode(rawValue: nsError.code)

                if case .networkError = oidErrorCode ?? .networkError, let accessToken = accessToken {
                    // Network error, so assume the token is still valid
                    return action(.success(accessToken))
                }

                return action(.failure(error))
            }
            
            guard let accessToken = accessToken else {
                return action(.failure(AuthError.notAuthenticated))
            }
            
            action(.success(accessToken))
        }
    }
}
