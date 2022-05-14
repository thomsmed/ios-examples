//
//  ExpandableDialogController.swift
//  DialogController
//
//  Created by Thomas Asheim Smedmann on 14/05/2022.
//

import UIKit

final class ExpandableDialogController: DialogController {

    override func loadView() {
        view = UIView()

        let eyesLabel = UILabel()
        eyesLabel.text = "👀"
        eyesLabel.textAlignment = .center
        eyesLabel.font = .systemFont(ofSize: 32, weight: .bold)

        let noseLabel = UILabel()
        noseLabel.text = "👃"
        noseLabel.textAlignment = .center
        noseLabel.font = .systemFont(ofSize: 32, weight: .bold)
        noseLabel.isHidden = true

        let mouthLabel = UILabel()
        mouthLabel.text = "👅"
        mouthLabel.textAlignment = .center
        mouthLabel.font = .systemFont(ofSize: 32, weight: .bold)
        mouthLabel.isHidden = true

        let stackView = UIStackView(arrangedSubviews: [
            eyesLabel,
            noseLabel,
            mouthLabel
        ])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill

        var step = 0
        let expandButton = UIButton(type: .system)
        expandButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        expandButton.setImage(.init(systemName: "chevron.down"), for: .normal)
        expandButton.addAction(.init(handler: { _ in
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                step = (step + 1) % 3
                noseLabel.isHidden = step == 0
                mouthLabel.isHidden = step != 2
                expandButton.setImage(
                    step == 2 ? .init(systemName: "chevron.up") : .init(systemName: "chevron.down"),
                    for: .normal
                )
            })
        }), for: .primaryActionTriggered)

        let closeButton = UIButton(type: .system)
        closeButton.setImage(.init(systemName: "xmark"), for: .normal)
        closeButton.addAction(.init(handler: { _ in
            self.dismiss(animated: true)
        }), for: .primaryActionTriggered)

        view.addSubview(closeButton)
        view.addSubview(stackView)
        view.addSubview(expandButton)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),

            stackView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            expandButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            expandButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            expandButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        view.backgroundColor = .systemBackground
    }
}
