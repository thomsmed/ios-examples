//
//  HomeViewController.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 23/01/2022.
//

import UIKit
import TinyConstraints

final class HomeViewController: UIViewController {

    private let hostButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedTinted()
        configuration.title = "Host a chat"
        configuration.buttonSize = .large
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    private let joinButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedTinted()
        configuration.title = "Join a chat"
        configuration.buttonSize = .large
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [hostButton, joinButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()

    override func loadView() {
        view = UIView()

        view.addSubview(stackView)

        stackView.leadingToSuperview(offset: 20)
        stackView.trailingToSuperview(offset: 20)
        stackView.centerYToSuperview(usingSafeArea: true)
        stackView.heightToSuperview(multiplier: 0.3)

        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "BLE Chat"

        hostButton.addAction(UIAction(handler: host), for: .primaryActionTriggered)
        joinButton.addAction(UIAction(handler: join), for: .primaryActionTriggered)
    }

    private func configureBehaviour() {
    }
    
    private func host(_ action: UIAction) {
        navigationController?.pushViewController(HostChatViewController(), animated: true)
    }
    
    private func join(_ action: UIAction) {
        navigationController?.pushViewController(JoinViewController(), animated: true)
    }
}
