//
//  ContentViewController.swift
//  CustomPresentationController
//
//  Created by Thomas Asheim Smedmann on 05/11/2021.
//

import UIKit

class ContentViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam malesuada vulputate mauris, vitae tristique lacus rhoncus id. Morbi mi leo, scelerisque et faucibus nec, egestas semper dolor. Etiam rutrum diam sit amet quam aliquet, vel vulputate ex blandit. Nam porta pretium ligula vel rutrum. Cras ultricies purus sit amet iaculis congue. Fusce pulvinar velit semper dolor sagittis vulputate. Vivamus ut sapien a tellus finibus pharetra. Sed at massa turpis. Nullam venenatis sodales nibh vel tempor. Cras pulvinar dui vel justo egestas, et viverra felis tincidunt. Suspendisse luctus elementum est, et venenatis est rhoncus at. Nulla maximus elit nisl, et congue nisl aliquet id.
        """
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(dismissButton)
        view.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            dismissButton.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
            dismissButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            dismissButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            contentLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        dismissButton.addTarget(self, action: #selector(onDismiss), for: .primaryActionTriggered)
    }
    
    @objc private func onDismiss() {
        dismiss(animated: true)
    }
}
