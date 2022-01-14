//
//  OkDialogController.swift
//  DialogController
//
//  Created by Thomas Asheim Smedmann on 09/05/2022.
//

import UIKit

final class OkDialogController: DialogController {

    override func loadView() {
        view = UIView()

        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        label.text = """
            Proin tempus dui tempor lectus tempor cursus. Aliquam vitae lorem id libero blandit faucibus.
        """

        let button = UIButton(type: .system)
        button.setTitle("Ok", for: .normal)
        button.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .primaryActionTriggered)

        view.addSubview(label)
        view.addSubview(button)

        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            button.topAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor, constant: 16),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        view.backgroundColor = .systemBackground
    }
}
