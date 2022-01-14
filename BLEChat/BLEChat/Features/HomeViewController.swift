//
//  HomeViewController.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 23/01/2022.
//

import UIKit
import TinyConstraints

class HomeViewController: UIViewController {
    private let hostButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedTinted()
        configuration.title = "Host"
        configuration.buttonSize = .large
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    private let joinButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedTinted()
        configuration.title = "Join"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BLE Chat"
        configureUI()
        configureBehaviour()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        stackView.leadingToSuperview(offset: 20)
        stackView.trailingToSuperview(offset: 20)
        stackView.centerYToSuperview(usingSafeArea: true)
        stackView.heightToSuperview(multiplier: 0.3)
    }

    private func configureBehaviour() {
        hostButton.addAction(UIAction(handler: host(_:)), for: .primaryActionTriggered)
        joinButton.addAction(UIAction(handler: join(_:)), for: .primaryActionTriggered)
    }
    
    private func host(_ action: UIAction) {
        navigationController?.pushViewController(HostedChatViewController(), animated: true)
    }
    
    private func join(_ action: UIAction) {
        navigationController?.pushViewController(JoinViewController(), animated: true)
    }
}
