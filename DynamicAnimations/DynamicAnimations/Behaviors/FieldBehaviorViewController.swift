//
//  FieldBehaviorViewController.swift
//  DynamicAnimations
//
//  Created by Thomas Asheim Smedmann on 18/07/2023.
//

import UIKit

final class FieldBehaviorViewController: UIViewController {
    private let animatorReferenceView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let radialFieldView: UIView = {
        let ballView = BallView()
        ballView.translatesAutoresizingMaskIntoConstraints = false
        ballView.gradientColors = [.systemRed, .clear]
        return ballView
    }()

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .tertiaryLabel
        label.text = "Tap to spawn more balls"
        return label
    }()

    private lazy var dynamicAnimator = UIDynamicAnimator(
        referenceView: animatorReferenceView
    )

    private lazy var radialGravityFieldBehavior = UIFieldBehavior.radialGravityField(
        position: .zero
    )
    private lazy var vortexFieldBehavior = UIFieldBehavior.vortexField()

    private lazy var collisionBehavior = UICollisionBehavior()

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

        animatorReferenceView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dynamicAnimator.removeAllBehaviors()

        radialGravityFieldBehavior.items.forEach { radialGravityFieldBehavior.removeItem($0) }
        vortexFieldBehavior.items.forEach { vortexFieldBehavior.removeItem($0) }
        collisionBehavior.items.forEach { collisionBehavior.removeItem($0) }
        collisionBehavior.removeAllBoundaries()

        animatorReferenceView.subviews.forEach { $0 !== hintLabel ? $0.removeFromSuperview() : Void() }
        animatorReferenceView.addSubview(radialFieldView)

        dynamicAnimator.addBehavior(radialGravityFieldBehavior)
        dynamicAnimator.addBehavior(vortexFieldBehavior)
        dynamicAnimator.addBehavior(collisionBehavior)

        let bounds = animatorReferenceView.bounds

        collisionBehavior.addBoundary(
            withIdentifier: "left" as NSCopying,
            from: CGPoint(x: bounds.minX, y: bounds.minY),
            to: CGPoint(x: bounds.minX, y: bounds.maxY)
        )
        collisionBehavior.addBoundary(
            withIdentifier: "right" as NSCopying,
            from: CGPoint(x: bounds.maxX, y: bounds.minY),
            to: CGPoint(x: bounds.maxX, y: bounds.maxY)
        )
        collisionBehavior.addBoundary(
            withIdentifier: "top" as NSCopying,
            from: CGPoint(x: bounds.minX, y: bounds.minY),
            to: CGPoint(x: bounds.maxX, y: bounds.minY)
        )
        collisionBehavior.addBoundary(
            withIdentifier: "bottom" as NSCopying,
            from: CGPoint(x: bounds.minX, y: bounds.maxY),
            to: CGPoint(x: bounds.maxX, y: bounds.maxY)
        )

        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius: CGFloat = min(bounds.width, bounds.height) / 2

        radialGravityFieldBehavior.position = center
        radialGravityFieldBehavior.region = UIRegion(radius: radius)
        radialGravityFieldBehavior.strength = 500
        radialGravityFieldBehavior.falloff = 1
        radialGravityFieldBehavior.minimumRadius = 15

        vortexFieldBehavior.position = center
        vortexFieldBehavior.region = UIRegion(radius: radius)
        vortexFieldBehavior.strength = 0.005
        vortexFieldBehavior.falloff = 1
        vortexFieldBehavior.minimumRadius = 15

        radialFieldView.frame.size = CGSize(width: radius * 2, height: radius * 2)
        radialFieldView.center = center
    }

    private func makeBallView(centeredAt center: CGPoint) -> BallView {
        let ballView = BallView()
        ballView.translatesAutoresizingMaskIntoConstraints = false
        ballView.backgroundColor = .systemBlue
        ballView.frame.size = CGSize(width: 15, height: 15)
        ballView.center = center
        return ballView
    }

    @objc private func onTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        switch tapGestureRecognizer.state {
            case .ended:
                let bounds = animatorReferenceView.bounds

                let ballView = makeBallView(
                    centeredAt: CGPoint(x: bounds.width / 2, y: bounds.height / 4)
                )

                animatorReferenceView.addSubview(ballView)

                radialGravityFieldBehavior.addItem(ballView)
                vortexFieldBehavior.addItem(ballView)
                collisionBehavior.addItem(ballView)
            default:
                break
        }
    }
}
