//
//  OkCancelDialogController.swift
//  DialogController
//
//  Created by Thomas Asheim Smedmann on 09/05/2022.
//

import UIKit

final class OkCancelDialogController: DialogController {

    override func loadView() {
        view = UIView()

        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        label.text = """
            Proin tempus dui tempor lectus tempor cursus. Aliquam vitae lorem id libero blandit faucibus.
        """

        let okButton = UIButton(type: .system)
        okButton.setTitle("Ok", for: .normal)
        okButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .primaryActionTriggered)

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .primaryActionTriggered)

        let horizontalStackView = UIStackView(arrangedSubviews: [
            okButton, cancelButton
        ])
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.alignment = .fill

        let verticalStackView = UIStackView(arrangedSubviews: [
            label, horizontalStackView
        ])
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fill
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 16

        view.addSubview(verticalStackView)
        view.addSubview(horizontalStackView)

        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            horizontalStackView.topAnchor.constraint(greaterThanOrEqualTo: verticalStackView.bottomAnchor),
            horizontalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        view.backgroundColor = .systemBackground
    }
}
