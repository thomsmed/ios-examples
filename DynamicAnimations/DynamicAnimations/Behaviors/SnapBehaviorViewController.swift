//
//  SnapBehaviorViewController.swift
//  DynamicAnimations
//
//  Created by Thomas Asheim Smedmann on 17/07/2023.
//

import UIKit

final class SnapBehaviorViewController: UIViewController {
    private let animatorReferenceView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .tertiaryLabel
        label.text = "Tap to change snap point"
        return label
    }()

    private let animatedView: UIView = {
        let ballView = BallView()
        ballView.translatesAutoresizingMaskIntoConstraints = false
        ballView.backgroundColor = .systemRed
        NSLayoutConstraint.activate([
            ballView.widthAnchor.constraint(equalToConstant: 150),
            ballView.heightAnchor.constraint(equalToConstant: 150),
        ])
        return ballView
    }()

    private let snapPointView: UIView = {
        let ballView = BallView()
        ballView.translatesAutoresizingMaskIntoConstraints = false
        ballView.backgroundColor = .systemBlue
        NSLayoutConstraint.activate([
            ballView.widthAnchor.constraint(equalToConstant: 15),
            ballView.heightAnchor.constraint(equalToConstant: 15),
        ])
        return ballView
    }()

    private lazy var dynamicAnimator = UIDynamicAnimator(
        referenceView: animatorReferenceView
    )

    private lazy var snapBehavior: UISnapBehavior = {
        let bounds = animatorReferenceView.bounds
        return UISnapBehavior(
            item: animatedView,
            snapTo: CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        )
    }()

    private lazy var tapGestureRecognizer = UITapGestureRecognizer(
        target: self, action: #selector(onTap)
    )

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .systemBackground

        view.addSubview(animatorReferenceView)

        NSLayoutConstraint.activate([
            animatorReferenceView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            animatorReferenceView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            animatorReferenceView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            animatorReferenceView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
        ])

        animatorReferenceView.addSubview(hintLabel)

        NSLayoutConstraint.activate([
            hintLabel.centerXAnchor.constraint(
                equalTo: animatorReferenceView.centerXAnchor
            ),
            hintLabel.centerYAnchor.constraint(
                equalTo: animatorReferenceView.centerYAnchor,
                constant: -200
            )
        ])

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        animatorReferenceView.addSubview(animatedView)
        animatorReferenceView.addSubview(snapPointView)

        animatorReferenceView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dynamicAnimator.removeAllBehaviors()

        snapPointView.center = snapBehavior.snapPoint

        dynamicAnimator.addBehavior(snapBehavior)
    }

    @objc private func onTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        switch tapGestureRecognizer.state {
            case .ended:
                snapBehavior.snapPoint = tapGestureRecognizer.location(
                    in: animatorReferenceView
                )
                snapPointView.center = snapBehavior.snapPoint
            default:
                break
        }
    }
}
