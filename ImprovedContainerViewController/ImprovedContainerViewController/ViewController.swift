//
//  ViewController.swift
//  ImprovedContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/08/2022.
//

import UIKit

final class ViewController: UIViewController {

    let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        return view
    }()

    let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()

    let nextButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.buttonSize = .large
        configuration.title = "Next"
        configuration.baseBackgroundColor = .systemGray6
        configuration.baseForegroundColor = .label
        let button = UIButton(configuration: configuration)
        return button
    }()

    let previousButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.buttonSize = .large
        configuration.title = "Previous"
        configuration.baseBackgroundColor = .systemGray6
        configuration.baseForegroundColor = .label
        let button = UIButton(configuration: configuration)
        button.isHidden = true
        return button
    }()

    override func loadView() {
        view = UIView()

        view.addSubview(cardView)

        cardView.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(label)
        cardView.addSubview(nextButton)
        cardView.addSubview(previousButton)

        label.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            label.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: -64),

            nextButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            nextButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: 64),

            previousButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            previousButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: 128)
        ])

        view.backgroundColor = .clear
    }
}
