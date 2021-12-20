//
//  ViewController.swift
//  CustomPresentationController
//
//  Created by Thomas Asheim Smedmann on 05/11/2021.
//

import UIKit

class ViewController: UIViewController {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            presentVisualEffectsViewButton,
            presentMotionEffectsViewButton,
            presentAlertAlertButton,
            presentAlertSheetButton,
            presentModalButton,
            presentPopoverButton,
            presentShelfButton,
            presentDialogButton,
            presentCustomShelfButton,
            presentCustomDialogButton
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let presentVisualEffectsViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Visual effects", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let presentMotionEffectsViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Motion effects", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let presentAlertAlertButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Alert alert", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let presentAlertSheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Alert sheet", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let presentModalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Modal", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let presentPopoverButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Popover", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let presentShelfButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Shelf", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let presentDialogButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dialog", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let presentCustomShelfButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Custom shelf", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let presentCustomDialogButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Custom dialog", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let shelfTransitionManager = ShelfTransitionManager()
    private let dialogTransitionManager = DialogTransitionManager()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        presentVisualEffectsViewButton.addTarget(self, action: #selector(showVisualEffectsView), for: .primaryActionTriggered)
        presentMotionEffectsViewButton.addTarget(self, action: #selector(showMotionEffectsView), for: .primaryActionTriggered)
        presentAlertAlertButton.addTarget(self, action: #selector(showAlertAlert), for: .primaryActionTriggered)
        presentAlertSheetButton.addTarget(self, action: #selector(showAlertSheet), for: .primaryActionTriggered)
        presentModalButton.addTarget(self, action: #selector(showModal), for: .primaryActionTriggered)
        presentPopoverButton.addTarget(self, action: #selector(showPopover), for: .primaryActionTriggered)
        presentShelfButton.addTarget(self, action: #selector(showShelf), for: .primaryActionTriggered)
        presentDialogButton.addTarget(self, action: #selector(showDialog), for: .primaryActionTriggered)
        presentCustomShelfButton.addTarget(self, action: #selector(showCustomShelf), for: .primaryActionTriggered)
        presentCustomDialogButton.addTarget(self, action: #selector(showCustomDialog), for: .primaryActionTriggered)
    }
    
    @objc private func showVisualEffectsView() {
        let visualEffectsViewController = VisualEffectsViewController()
        visualEffectsViewController.modalPresentationStyle = .pageSheet
        present(visualEffectsViewController, animated: true)
    }
    
    @objc private func showMotionEffectsView() {
        let motionEffectsViewController = MotionEffectsViewController()
        motionEffectsViewController.modalPresentationStyle = .pageSheet
        present(motionEffectsViewController, animated: true)
    }
    
    @objc private func showAlertAlert() {
        let alert = UIAlertController(title: "Some alert title", message: "Some alert message", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func showAlertSheet() {
        let alert = UIAlertController(title: "Some alert title", message: "Some alert message", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func showModal() {
        let contentViewController = ContentViewController()
        contentViewController.modalPresentationStyle = .currentContext
        present(contentViewController, animated: true)
    }
    
    @objc private func showPopover() {
        let contentViewController = ContentViewController()
        contentViewController.modalPresentationStyle = .popover
        present(contentViewController, animated: true)
    }
    
    @objc private func showShelf() {
        let contentViewController = ContentViewController()
        contentViewController.modalPresentationStyle = .pageSheet
        present(contentViewController, animated: true)
    }
    
    @objc private func showDialog() {
        let contentViewController = ContentViewController()
        contentViewController.modalPresentationStyle = .formSheet
        present(contentViewController, animated: true)
    }
    
    @objc private func showCustomShelf() {
        let contentViewController = ContentViewController()
        contentViewController.modalPresentationStyle = .custom
        contentViewController.transitioningDelegate = shelfTransitionManager
        present(contentViewController, animated: true)
    }
    
    @objc private func showCustomDialog() {
        let contentViewController = ContentViewController()
        contentViewController.modalPresentationStyle = .custom
        contentViewController.transitioningDelegate = dialogTransitionManager
        present(contentViewController, animated: true)
    }
}

