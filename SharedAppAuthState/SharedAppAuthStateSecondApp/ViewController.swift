//
//  ViewController.swift
//  SharedAppAuthStateSecondApp
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import UIKit
import TinyConstraints

struct Dependencies {
    private static let migrationRepository: AuthStateRepository = SharedUserDefaultsAuthStateRepository(appGroupIdentifier: "group.com.my.app")
    private static let authStateRepository: AuthStateRepository = KeyChainAuthStateRepository(accessGroup: "<TeamId>.com.my.app",
                                                                                            serviceName: "com.my.app",
                                                                                            accountName: "My App",
                                                                                            migrationRepository: migrationRepository)
    private static let auth0AuthService = Auth0AuthService(configuration: Auth0Configuration(openIdDomain: "<openIdDomain>",
                                                                                           openIdClientId: "<openIdClientId>",
                                                                                           issuer: URL(string: "<openIdIssuer>")!,
                                                                                           callbackUrl: URL(string: "com.my.app://app/authentication")!),
                                                         authStateRepository: authStateRepository)
    static let authService: AuthService = auth0AuthService
    static let authTokenProvider: AuthTokenProvider = auth0AuthService
}

enum TextType {
    case info
    case error
    
    var uiColor: UIColor {
        switch self {
        case .info:
            return .label
        case .error:
            return .systemRed
        }
    }
}

class ViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.text = "Hello from Second App"
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private let callApiButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Call Api!", for: .normal)
        return button
    }()
    
    private var isAuthenticated = false {
        didSet {
            callApiButton.isHidden = !isAuthenticated
            loginButton.setTitle(isAuthenticated ? "Sign out" : "Sign in", for: .normal)
            showStatus(isAuthenticated ? "You are signed in!" : "You are not signed in")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBehaviour()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(loginButton)
        view.addSubview(statusLabel)
        view.addSubview(callApiButton)
        
        titleLabel.topToSuperview(offset: 40, usingSafeArea: true)
        titleLabel.leadingToSuperview(offset: 40, usingSafeArea: true)
        
        loginButton.centerXToSuperview()
        loginButton.centerYToSuperview(offset: -40)
        
        statusLabel.centerInSuperview()
        
        callApiButton.centerXToSuperview()
        callApiButton.centerYToSuperview(offset: 40)
    }
    
    private func configureBehaviour() {
        loginButton.addTarget(self, action: #selector(loginOrLogout), for: .primaryActionTriggered)
        callApiButton.addTarget(self, action: #selector(callApi), for: .primaryActionTriggered)
        
        isAuthenticated = Dependencies.authService.hasSignedInBefore
    }
    
    private func showStatus(_ text: String, type: TextType = .info) {
        statusLabel.text = text
        statusLabel.textColor = type.uiColor
    }
    
    @objc private func loginOrLogout(_ target: UIButton) {
        if isAuthenticated {
            logout()
        } else {
            login()
        }
    }
    
    @objc private func callApi(_ target: UIButton) {
        callFakeApi()
    }
}

extension ViewController {
    func login() {
        Dependencies.authService.login { result in
            switch result {
            case let .failure(error):
                self.showStatus(error.localizedDescription, type: .error)
            case .success:
                self.isAuthenticated = true
            }
        }
    }
    
    func logout() {
        Dependencies.authService.logout()
        isAuthenticated = false
    }
    
    func callFakeApi() {
        Dependencies.authTokenProvider.performWithFreshToken { tokenResult in
            switch tokenResult {
            case let .failure(error):
                self.showStatus(error.localizedDescription, type: .error)
            case let .success(accessToken):
                self.showStatus("Calling api... (token: \(accessToken.dropLast(accessToken.count - 5))...)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showStatus("Success! (token: \(accessToken.dropLast(accessToken.count - 5))...)")
                }
            }
        }
    }
}
