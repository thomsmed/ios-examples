//
//  ViewController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 04/05/2022.
//

import UIKit

final class ViewController: UIViewController {

    private let stackView = UIStackView()

    override func loadView() {
        view = UIView()

        let sparseContentFitButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = SparseContentSheetViewController()
            viewController.preferredSheetSizing = .fit
            self.present(viewController, animated: true)
        }))
        sparseContentFitButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        sparseContentFitButton.setTitle("Sparse content - fit", for: .normal)

        let sparseContentSmallButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = SparseContentSheetViewController()
            viewController.preferredSheetSizing = .small
            self.present(viewController, animated: true)
        }))
        sparseContentSmallButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        sparseContentSmallButton.setTitle("Sparse content - small", for: .normal)

        let sparseContentMediumButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = SparseContentSheetViewController()
            viewController.preferredSheetSizing = .medium
            self.present(viewController, animated: true)
        }))
        sparseContentMediumButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        sparseContentMediumButton.setTitle("Sparse content - medium", for: .normal)

        let sparseContentLargeButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = SparseContentSheetViewController()
            viewController.preferredSheetSizing = .large
            self.present(viewController, animated: true)
        }))
        sparseContentLargeButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        sparseContentLargeButton.setTitle("Sparse content - large", for: .normal)

        let sparseContentFillButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = SparseContentSheetViewController()
            viewController.preferredSheetSizing = .fill
            self.present(viewController, animated: true)
        }))
        sparseContentFillButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        sparseContentFillButton.setTitle("Sparse content - fill", for: .normal)

        let sparseContentStackView = UIStackView(arrangedSubviews: [
            sparseContentFitButton,
            sparseContentSmallButton,
            sparseContentMediumButton,
            sparseContentLargeButton,
            sparseContentFillButton
        ])
        sparseContentStackView.axis = .vertical
        sparseContentStackView.spacing = 8

        let denseContentFitButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = DenseContentSheetViewController()
            viewController.preferredSheetSizing = .fit
            self.present(viewController, animated: true)
        }))
        denseContentFitButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        denseContentFitButton.setTitle("Dense content - fit", for: .normal)

        let denseContentSmallButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = DenseContentSheetViewController()
            viewController.preferredSheetSizing = .small
            self.present(viewController, animated: true)
        }))
        denseContentSmallButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        denseContentSmallButton.setTitle("Dense content - small", for: .normal)

        let denseContentMediumButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = DenseContentSheetViewController()
            viewController.preferredSheetSizing = .medium
            self.present(viewController, animated: true)
        }))
        denseContentMediumButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        denseContentMediumButton.setTitle("Dense content - medium", for: .normal)

        let denseContentLargeButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = DenseContentSheetViewController()
            viewController.preferredSheetSizing = .large
            self.present(viewController, animated: true)
        }))
        denseContentLargeButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        denseContentLargeButton.setTitle("Dense content - large", for: .normal)

        let denseContentFillButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = DenseContentSheetViewController()
            viewController.preferredSheetSizing = .fill
            self.present(viewController, animated: true)
        }))
        denseContentFillButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        denseContentFillButton.setTitle("Dense content - fill", for: .normal)

        let denseContentStackView = UIStackView(arrangedSubviews: [
            denseContentFitButton,
            denseContentSmallButton,
            denseContentMediumButton,
            denseContentLargeButton,
            denseContentFillButton
        ])
        denseContentStackView.axis = .vertical
        denseContentStackView.spacing = 8

        let expandingContentMediumButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = ExpandingContentSheetViewController()
            viewController.preferredSheetSizing = .fit
            self.present(viewController, animated: true)
        }))
        expandingContentMediumButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        expandingContentMediumButton.setTitle("Expanding content - fit", for: .normal)

        let axis: NSLayoutConstraint.Axis = traitCollection.horizontalSizeClass == .compact ? .vertical : .horizontal
        stackView.addArrangedSubview(sparseContentStackView)
        stackView.addArrangedSubview(denseContentStackView)
        stackView.addArrangedSubview(expandingContentMediumButton)
        stackView.axis = axis
        stackView.spacing = 16

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        view.backgroundColor = .systemBackground
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let axis: NSLayoutConstraint.Axis = traitCollection.horizontalSizeClass == .compact ? .vertical : .horizontal
        stackView.axis = axis
    }
}
