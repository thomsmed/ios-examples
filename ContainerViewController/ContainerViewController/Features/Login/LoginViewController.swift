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

    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        button.addTarget(self, action: #selector(signIn), for: .primaryActionTriggered)
    }

    @objc private func signIn(_ target: UIButton) {
        viewModel.signIn()
    }
}

extension LoginViewController {

    override func loadView() {
        view = UIView()

        view.addSubview(label)
        view.addSubview(button)

        constrain(label, button, view) { label, button, container in
            label.centerX == container.centerX
            label.centerY == container.centerY - 120

            button.centerX == container.centerX
            button.centerY == container.centerY + 20
        }

        view.backgroundColor = .systemGray4
    }
}
