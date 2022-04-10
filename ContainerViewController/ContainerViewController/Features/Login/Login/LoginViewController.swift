//
//  LoginViewController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit
import Cartography

final class LoginViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .orange
        label.text = "Login"
        return label
    }()

    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.secondaryLabel, for: .normal)
        return button
    }()

    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        title = "Login"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.addTarget(self, action: #selector(signIn), for: .primaryActionTriggered)
        registerButton.addTarget(self, action: #selector(register), for: .primaryActionTriggered)
    }

    @objc private func signIn(_ target: UIButton) {
        viewModel.signIn()
    }

    @objc private func register(_ target: UIButton) {
        viewModel.register()
    }
}

extension LoginViewController {

    override func loadView() {
        view = UIView()

        view.addSubview(label)
        view.addSubview(signInButton)
        view.addSubview(registerButton)

        constrain(label, signInButton, registerButton, view) { label, signInButton, registerButton, container in
            label.centerX == container.centerX
            label.centerY == container.centerY - 120

            signInButton.centerX == container.centerX
            signInButton.centerY == container.centerY + 20

            registerButton.top == signInButton.bottom + 10
            registerButton.centerX == container.centerX
        }

        view.backgroundColor = .systemGray4
    }
}
