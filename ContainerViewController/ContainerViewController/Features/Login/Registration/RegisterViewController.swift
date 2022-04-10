//
//  RegisterViewController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 10/04/2022.
//

import UIKit
import Cartography

final class RegisterViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .cyan
        label.text = "Register"
        return label
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    private let viewModel: RegisterViewModel

    init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        title = "Register"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerButton.addTarget(self, action: #selector(register), for: .primaryActionTriggered)
    }

    @objc private func register(_ target: UIButton) {
        viewModel.register()
    }
}

extension RegisterViewController {

    override func loadView() {
        view = UIView()

        view.addSubview(label)
        view.addSubview(registerButton)

        constrain(label, registerButton, view) { label, registerButton, container in
            label.centerX == container.centerX
            label.centerY == container.centerY - 120

            registerButton.centerX == container.centerX
            registerButton.centerY == container.centerY + 20
        }

        view.backgroundColor = .systemGray4
    }
}
