//
//  FormDialogController.swift
//  DialogController
//
//  Created by Thomas Asheim Smedmann on 09/05/2022.
//

import UIKit

final class FormDialogController: DialogController {

    override func loadView() {
        view = UIView()

        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        label.text = """
            Proin tempus dui tempor lectus tempor cursus. Aliquam vitae lorem id libero blandit faucibus.
        """

        let textFieldOne = UITextField()
        textFieldOne.placeholder = "Name"
        textFieldOne.font = .systemFont(ofSize: 17, weight: .regular)

        let textFieldTwo = UITextField()
        textFieldOne.placeholder = "Description"
        textFieldTwo.font = .systemFont(ofSize: 17, weight: .regular)

        let switchOneLabel = UILabel()
        switchOneLabel.text = "Camera"
        switchOneLabel.textAlignment = .right
        let switchOneStackView = UIStackView(arrangedSubviews: [UISwitch(), switchOneLabel])
        switchOneStackView.axis = .horizontal
        switchOneStackView.distribution = .fill
        switchOneStackView.alignment = .fill

        let switchTwoLabel = UILabel()
        switchTwoLabel.text = "Sound"
        switchTwoLabel.textAlignment = .left
        let switchTwoStackView = UIStackView(arrangedSubviews: [switchTwoLabel, UISwitch()])
        switchTwoStackView.axis = .horizontal
        switchTwoStackView.distribution = .fill
        switchTwoStackView.alignment = .fill

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
            label,
            textFieldOne,
            switchOneStackView,
            textFieldTwo,
            switchTwoStackView
        ])
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fill
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 8

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
