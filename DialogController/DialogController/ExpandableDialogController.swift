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
        eyesLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let noseLabel = UILabel()
        noseLabel.text = "👃"
        noseLabel.textAlignment = .center
        noseLabel.font = .systemFont(ofSize: 32, weight: .bold)
        noseLabel.isHidden = true
        noseLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let mouthLabel = UILabel()
        mouthLabel.text = "👅"
        mouthLabel.textAlignment = .center
        mouthLabel.font = .systemFont(ofSize: 32, weight: .bold)
        mouthLabel.isHidden = true
        mouthLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let faceStackView = UIStackView(arrangedSubviews: [
            eyesLabel,
            noseLabel,
            mouthLabel
        ])
        faceStackView.axis = .vertical
        faceStackView.distribution = .fill
        faceStackView.alignment = .fill

        let leftHandLabel = UILabel()
        leftHandLabel.text = "✋"
        leftHandLabel.textAlignment = .center
        leftHandLabel.font = .systemFont(ofSize: 32, weight: .bold)
        leftHandLabel.isHidden = true
        leftHandLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let rightHandLabel = UILabel()
        rightHandLabel.text = "🤚"
        rightHandLabel.textAlignment = .center
        rightHandLabel.font = .systemFont(ofSize: 32, weight: .bold)
        rightHandLabel.isHidden = true
        rightHandLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let bodyStackView = UIStackView(arrangedSubviews: [
            leftHandLabel,
            faceStackView,
            rightHandLabel
        ])
        bodyStackView.axis = .horizontal
        bodyStackView.distribution = .fill
        bodyStackView.alignment = .fill
        bodyStackView.spacing = 16

        var step = 0
        let expandButton = UIButton(type: .system)
        expandButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        expandButton.setImage(.init(systemName: "chevron.down"), for: .normal)
        expandButton.addAction(.init(handler: { _ in
            step = (step + 1) % 3

            leftHandLabel.alpha = step > 1 ? 1 : 0
            rightHandLabel.alpha = step > 1 ? 1 : 0

            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                noseLabel.isHidden = step == 0
                mouthLabel.isHidden = step != 2

                leftHandLabel.isHidden = step < 2
                rightHandLabel.isHidden = step < 2

                expandButton.setImage(
                    step == 2 ? .init(systemName: "chevron.up") : .init(systemName: "chevron.down"),
                    for: .normal
                )

                let font: UIFont
                if step == 2 {
                    font = .systemFont(ofSize: 72, weight: .regular)
                } else {
                    font = .systemFont(ofSize: 32, weight: .regular)
                }

                eyesLabel.font = font
                noseLabel.font = font
                mouthLabel.font = font
                leftHandLabel.font = font
                rightHandLabel.font = font
            })
        }), for: .primaryActionTriggered)

        view.addSubview(bodyStackView)
        view.addSubview(expandButton)

        bodyStackView.translatesAutoresizingMaskIntoConstraints = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bodyStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16
            ),
            bodyStackView.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor
            ),
            bodyStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16
            ),
            bodyStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16
            ),

            expandButton.topAnchor.constraint(
                equalTo: bodyStackView.bottomAnchor, constant: 16
            ),
            expandButton.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor
            ),
            expandButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16
            )
        ])

        view.backgroundColor = .systemBackground
    }
}
