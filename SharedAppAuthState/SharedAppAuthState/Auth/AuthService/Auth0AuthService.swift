//
//  Auth0AuthService.swift
//  SharedAppAuthState
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import Foundation
import Combine
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
    
    private lazy var stateSubject = CurrentValueSubject<AuthServiceState, Never>(hasSignedInBefore ? .authenticated : .unauthenticated)
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    init(configuration: Auth0Configuration, authStateRepository: AuthStateRepository) {
        self.configuration = configuration
        self.authStateRepository = authStateRepository
    }
    
    var hasSignedInBefore: Bool {
        authStateRepository.state != nil
    }
    
    var state: AnyPublisher<AuthServiceState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    private func notifyNeedReauthentication() {
        if stateSubject.value == .needReathentication { return }
        stateSubject.send(.needReathentication)
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
            
            self.stateSubject.send(.authenticated)
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
        stateSubject.send(.unauthenticated)
    }
}

extension Auth0AuthService: AuthTokenProvider {
    func performWithFreshToken(_ action: @escaping (Result<String, Error>) -> Void) {
        guard let authState = authStateRepository.state else {
            return action(.failure(AuthError.notAuthenticated))
        }

        authState.performAction { [unowned self] (accessToken, idToken, error) in
            if let error = error {
                self.notifyNeedReauthentication()
                return action(.failure(error))
            }

            guard let accessToken = accessToken else {
                self.notifyNeedReauthentication()
                return action(.failure(AuthError.notAuthenticated))
            }

            action(.success(accessToken))
        }
    }
}
