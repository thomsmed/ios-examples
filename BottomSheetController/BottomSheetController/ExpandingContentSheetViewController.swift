//
//  ExpandingContentSheetViewController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 14/05/2022.
//

import UIKit

final class ExpandingContentSheetViewController: BottomSheetController {

    override func loadView() {
        view = UIView()

        let labelOne = UILabel()
        labelOne.font = .systemFont(ofSize: 24, weight: .regular)
        labelOne.text = "Hello there! 👋🧔🏼‍♂️"

        let labelTwo = UILabel()
        labelTwo.font = .systemFont(ofSize: 24, weight: .regular)
        labelTwo.text = "General Kenobi... 🫵🤖"
        labelTwo.isHidden = true
        labelTwo.alpha = 0

        let expandButton = UIButton(type: .system)
        expandButton.setImage(.init(systemName: "chevron.up"), for: .normal)
        expandButton.addAction(.init(handler: { _ in
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                labelTwo.isHidden = !labelTwo.isHidden
                labelTwo.alpha = labelTwo.isHidden ? 0 : 1
                expandButton.setImage(
                    labelTwo.isHidden ? .init(systemName: "chevron.up") : .init(systemName: "chevron.down"),
                    for: .normal
                )
            })
        }), for: .primaryActionTriggered)

        let horizontalStackView = UIStackView(arrangedSubviews: [labelOne, expandButton])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 16

        let verticalStackView = UIStackView(arrangedSubviews: [horizontalStackView, labelTwo])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 16

        var configuration: UIButton.Configuration = .borderless()
        configuration.image = .init(systemName: "xmark")
        let closeButton = UIButton(configuration: configuration, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        }))

        view.addSubview(closeButton)
        view.addSubview(verticalStackView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            labelTwo.heightAnchor.constraint(equalToConstant: 100),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),

            verticalStackView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 32),
            verticalStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            verticalStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        view.backgroundColor = .systemBackground
    }
}
