//
//  LifecycleDependentContentSheetViewController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 19/05/2023.
//

import UIKit

final class LifecycleDependentContentSheetViewController: BottomSheetController {

    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .regular)
        return label
    }()

    override func loadView() {
        view = UIView()

        var configuration: UIButton.Configuration = .borderless()
        configuration.image = .init(systemName: "xmark")
        let button = UIButton(configuration: configuration, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        }))

        view.addSubview(button)
        view.addSubview(textLabel)

        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),

            textLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            textLabel.topAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor),
            textLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor),
            textLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        textLabel.transform = .init(rotationAngle: .pi)

        view.backgroundColor = .systemBackground
    }
}

extension LifecycleDependentContentSheetViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        textLabel.text = "View will appear!"

        guard transitionCoordinator?.isAnimated ?? false else {
            self.textLabel.transform = .identity

            return
        }

        transitionCoordinator?.animate { _ in
            self.textLabel.transform = .identity
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        textLabel.text = "View did appear!"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        textLabel.text = "View will disappear!"

        guard transitionCoordinator?.isAnimated ?? false else {
            return
        }

        transitionCoordinator?.animate { _ in
            self.textLabel.transform = .init(rotationAngle: .pi)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        textLabel.text = "View did disappear!"
    }
}
