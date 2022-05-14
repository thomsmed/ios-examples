//
//  ViewController.swift
//  DialogController
//
//  Created by Thomas Asheim Smedmann on 09/05/2022.
//

import UIKit

final class ViewController: UIViewController {

    override func loadView() {
        view = UIView()

        let dialogFitButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = OkDialogController()
            viewController.preferredDialogSizing = .init(horizontal: .fit, vertical: .fit)
            self.present(viewController, animated: true)
        }))
        dialogFitButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        dialogFitButton.setTitle("Ok dialog - fit/fit", for: .normal)

        let dialogSmallButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = OkDialogController()
            viewController.preferredDialogSizing = .init(horizontal: .small, vertical: .matching)
            self.present(viewController, animated: true)
        }))
        dialogSmallButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        dialogSmallButton.setTitle("Ok dialog - small/appropriate", for: .normal)

        let dialogMediumFitButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = OkCancelDialogController()
            viewController.preferredDialogSizing = .init(horizontal: .medium, vertical: .fit)
            self.present(viewController, animated: true)
        }))
        dialogMediumFitButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        dialogMediumFitButton.setTitle("Ok/Cancel dialog - medium/fit", for: .normal)

        let dialogMediumButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = OkCancelDialogController()
            viewController.preferredDialogSizing = .init(horizontal: .medium, vertical: .matching)
            self.present(viewController, animated: true)
        }))
        dialogMediumButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        dialogMediumButton.setTitle("Ok/Cancel dialog - medium/appropriate", for: .normal)

        let dialogMediumFillButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = OkCancelDialogController()
            viewController.preferredDialogSizing = .init(horizontal: .medium, vertical: .fill)
            self.present(viewController, animated: true)
        }))
        dialogMediumFillButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        dialogMediumFillButton.setTitle("Ok/Cancel dialog - medium/fill", for: .normal)

        let dialogLargeButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = FormDialogController()
            viewController.preferredDialogSizing = .init(horizontal: .large, vertical: .matching)
            self.present(viewController, animated: true)
        }))
        dialogLargeButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        dialogLargeButton.setTitle("Form dialog - large/appropriate", for: .normal)

        let dialogFillButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = FormDialogController()
            viewController.preferredDialogSizing = .init(horizontal: .fill, vertical: .fill)
            self.present(viewController, animated: true)
        }))
        dialogFillButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        dialogFillButton.setTitle("Form dialog - fill/fill", for: .normal)

        let dialogExpandableButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = ExpandableDialogController()
            viewController.preferredDialogSizing = .init(horizontal: .small, vertical: .fit)
            self.present(viewController, animated: true)
        }))
        dialogExpandableButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        dialogExpandableButton.setTitle("Expandable dialog - small/fit", for: .normal)

        let stackView = UIStackView(arrangedSubviews: [
            dialogFitButton,
            dialogSmallButton,
            dialogMediumFitButton,
            dialogMediumButton,
            dialogMediumFillButton,
            dialogLargeButton,
            dialogFillButton,
            dialogExpandableButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 8

        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])

        view.backgroundColor = .systemBackground
    }

}

