//
//  FittingPageViewController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 04/05/2022.
//

import UIKit

class FittingPageViewController: BottomSheetController {

    override func loadView() {
        view = UIView()

        let label = UILabel()
        label.text = "Hello"
        label.textColor = .black

        var configuration: UIButton.Configuration = .borderless()
        configuration.image = .remove
        let button = UIButton(configuration: configuration, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        }))

        view.addSubview(button)
        view.addSubview(label)

        button.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            button.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor),

            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            label.topAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor),
            label.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        view.backgroundColor = .white
    }
}
