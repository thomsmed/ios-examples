//
//  ViewController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 04/05/2022.
//

import UIKit

final class ViewController: UIViewController {

    override func loadView() {
        view = UIView()

        let sparseContentFitButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = SparseContentSheetViewController()
            viewController.preferredSheetSizing = .fit
            self.present(viewController, animated: true)
        }))
        sparseContentFitButton.setTitle("Sparse content - fit", for: .normal)

        let sparseContentSmallButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = SparseContentSheetViewController()
            viewController.preferredSheetSizing = .small
            self.present(viewController, animated: true)
        }))
        sparseContentSmallButton.setTitle("Sparse content - small", for: .normal)

        let sparseContentMediumButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = SparseContentSheetViewController()
            viewController.preferredSheetSizing = .medium
            self.present(viewController, animated: true)
        }))
        sparseContentMediumButton.setTitle("Sparse content - medium", for: .normal)

        let sparseContentLargeButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = SparseContentSheetViewController()
            viewController.preferredSheetSizing = .large
            self.present(viewController, animated: true)
        }))
        sparseContentLargeButton.setTitle("Sparse content - large", for: .normal)

        let sparseContentFillButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = SparseContentSheetViewController()
            viewController.preferredSheetSizing = .fill
            self.present(viewController, animated: true)
        }))
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
        denseContentFitButton.setTitle("Dense content - fit", for: .normal)

        let denseContentSmallButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = DenseContentSheetViewController()
            viewController.preferredSheetSizing = .small
            self.present(viewController, animated: true)
        }))
        denseContentSmallButton.setTitle("Dense content - small", for: .normal)

        let denseContentMediumButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = DenseContentSheetViewController()
            viewController.preferredSheetSizing = .medium
            self.present(viewController, animated: true)
        }))
        denseContentMediumButton.setTitle("Dense content - medium", for: .normal)

        let denseContentLargeButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = DenseContentSheetViewController()
            viewController.preferredSheetSizing = .large
            self.present(viewController, animated: true)
        }))
        denseContentLargeButton.setTitle("Dense content - large", for: .normal)

        let denseContentFillButton = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = DenseContentSheetViewController()
            viewController.preferredSheetSizing = .fill
            self.present(viewController, animated: true)
        }))
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


        let stackView = UIStackView(arrangedSubviews: [
            sparseContentStackView,
            denseContentStackView
        ])
        stackView.axis = .vertical
        stackView.spacing = 16

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        view.backgroundColor = .systemBackground
    }
}
