//
//  AppBlockedViewController.swift
//  ExtendedSplashScreen
//
//  Created by Thomas Asheim Smedmann on 19/04/2023.
//

import UIKit

final class AppBlockedViewController: UIViewController {

    override func loadView() {
        view = UIView()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24)
        label.text = "Sorry. You need to reinstall the app."
        label.textAlignment = .center
        label.numberOfLines = 0

        view.addSubview(label)

        let trailingConstraint = label.trailingAnchor.constraint(
            equalTo: view.trailingAnchor, constant: -16
        )
        trailingConstraint.priority = .required - 1 // To prevent any initial layout conflicts.

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trailingConstraint,
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
