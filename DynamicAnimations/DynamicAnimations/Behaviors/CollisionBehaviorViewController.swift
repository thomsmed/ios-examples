//
//  CollisionBehaviorViewController.swift
//  DynamicAnimations
//
//  Created by Thomas Asheim Smedmann on 17/07/2023.
//

import UIKit

final class CollisionBehaviorViewController: UIViewController {
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
        label.text = "Tap to drop more balls"
        return label
    }()

    private lazy var dynamicAnimator = UIDynamicAnimator(
        referenceView: animatorReferenceView
    )

    private lazy var ballItemBehavior: UIDynamicItemBehavior = {
        let dynamicItemBehavior = UIDynamicItemBehavior()
        dynamicItemBehavior.elasticity = 0.5
        dynamicItemBehavior.density = 1
        return dynamicItemBehavior
    }()

    private lazy var gravityBehavior = UIGravityBehavior()

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

        ballItemBehavior.items.forEach { ballItemBehavior.removeItem($0) }
        gravityBehavior.items.forEach { gravityBehavior.removeItem($0) }
        collisionBehavior.items.forEach { collisionBehavior.removeItem($0) }
        collisionBehavior.removeAllBoundaries()

        animatorReferenceView.subviews.forEach {
            $0 !== hintLabel ? $0.removeFromSuperview() : Void()
        }

        dynamicAnimator.addBehavior(ballItemBehavior)
        dynamicAnimator.addBehavior(gravityBehavior)
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
            withIdentifier: "bottom" as NSCopying,
            from: CGPoint(x: bounds.minX, y: bounds.maxY),
            to: CGPoint(x: bounds.maxX, y: bounds.maxY)
        )
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
                    centeredAt: CGPoint(x: bounds.width / 2, y: -100)
                )

                animatorReferenceView.addSubview(ballView)

                ballItemBehavior.addItem(ballView)
                gravityBehavior.addItem(ballView)
                collisionBehavior.addItem(ballView)
            default:
                break
        }
    }
}
