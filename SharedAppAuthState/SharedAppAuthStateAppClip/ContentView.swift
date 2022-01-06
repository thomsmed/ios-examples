//
//  ContentView.swift
//  SharedAppAuthStateAppClip
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import SwiftUI

struct Dependencies {
    private static let authStateRepository: AuthStateRepository = SharedUserDefaultsAuthStateRepository(appGroupIdentifier: "group.com.mydomain.shared")
    private static let auth0AuthService = Auth0AuthService(configuration: Auth0Configuration(openIdDomain: "<openIdDomain>",
                                                                                             openIdClientId: "<openIdClientId",
                                                                                             issuer: URL(string: "https://openid.issuer.com")!,
                                                                                             callbackUrl: URL(string: "com.thomsmed.SharedAppAuthState://app/authentication")!),
                                                           authStateRepository: authStateRepository)
    static let authService: AuthService = auth0AuthService
    static let authTokenProvider: AuthTokenProvider = auth0AuthService
}

struct ContentView: View {
    @State var isAuthenticated = Dependencies.authService.hasSignedInBefore
    @State var state: String = Dependencies.authService.hasSignedInBefore ? "You are signed in!" : "You are not signed in"
    
    var body: some View {
        VStack() {
            Text("Hello from App Clip").padding()
            Button(isAuthenticated ? "Sign out" : "Sign in", action: {
                if isAuthenticated {
                    Dependencies.authService.logout()
                    isAuthenticated = false
                    state = "You are not signed in"
                } else {
                    Dependencies.authService.login { result in
                        switch result {
                        case let .failure(error):
                            state = error.localizedDescription
                        case .success:
                            isAuthenticated = true
                            state = "You are signed in!"
                        }
                    }
                }
            })
            Text(state).padding()
            if isAuthenticated {
                Button("Call Api!", action: {
                    Dependencies.authTokenProvider.performWithFreshToken { tokenResult in
                        switch tokenResult {
                        case let .failure(error):
                            state = error.localizedDescription
                        case let .success(accessToken):
                            state = "Calling api... (token: \(accessToken.dropLast(accessToken.count - 5))...)"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                state = "Success! (token: \(accessToken.dropLast(accessToken.count - 5))...)"
                            }
                        }
                    }
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
