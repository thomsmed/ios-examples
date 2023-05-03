//
//  BouncyCubeViewController.swift
//  InteractiveAnimations
//
//  Created by Thomas Asheim Smedmann on 02/05/2023.
//

import UIKit

final class BouncyCubeViewController: UIViewController {
    private lazy var cubeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemRed
        return view
    }()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer(
            target: self, action: #selector(onPan)
        )
        return gestureRecognizer
    }()

    private var animator: Animator = Animator()

    override func loadView() {
        let view = UIView()

        view.addSubview(cubeView)

        let defaultCenterXConstraint = cubeView.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        )
        // Slightly lower the priority to prevent conflicts with the animator.
        defaultCenterXConstraint.priority = .required - 1

        let defaultCenterYConstraint = cubeView.centerYAnchor.constraint(
            equalTo: view.centerYAnchor
        )
        // Slightly lower the priority to prevent conflicts with the animator.
        defaultCenterYConstraint.priority = .required - 1

        NSLayoutConstraint.activate([
            cubeView.widthAnchor.constraint(equalToConstant: 100),
            cubeView.heightAnchor.constraint(equalTo: cubeView.widthAnchor),
            defaultCenterXConstraint,
            defaultCenterYConstraint
        ])

        animator.centerXConstraint = cubeView.centerXAnchor.constraint(
            equalTo: view.leadingAnchor
        )
        animator.centerYConstraint = cubeView.centerYAnchor.constraint(
            equalTo: view.topAnchor
        )

        view.backgroundColor = .systemBackground

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        cubeView.addGestureRecognizer(panGestureRecognizer)
    }

    @objc
    private func onPan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let view = panGestureRecognizer.view else {
            return
        }

        let translation = panGestureRecognizer.translation(in: view.superview)

        switch panGestureRecognizer.state {
            case .possible:
                break
            case .failed:
                break
            case .began:
                animator.start(animating: view)
            case .changed:
                animator.move(view, basedOn: translation)
            default: // .ended, .cancelled, @unknown
                let velocity = panGestureRecognizer.velocity(in: view.superview)
                animator.stop(animating: view, with: velocity)
        }
    }
}

fileprivate final class Animator {
    var centerXConstraint: NSLayoutConstraint?
    var centerYConstraint: NSLayoutConstraint?

    private var initialCubeCenter: CGPoint = .zero

    private var offsetAnimator: UIViewPropertyAnimator?

    private func initialVelocity(
        basedOn gestureVelocity: CGPoint,
        startingAt currentPosition: CGPoint,
        endingAt finalPosition: CGPoint
    ) -> CGVector {
        // Tip on how to calculate initial velocity:
        // https://developer.apple.com/documentation/uikit/uispringtimingparameters/1649909-initialvelocity
        let xDistance = finalPosition.x - currentPosition.x
        let yDistance = finalPosition.y - currentPosition.y

        return CGVector(
            dx: xDistance != 0 ? gestureVelocity.x / xDistance : 0,
            dy: yDistance != 0 ? gestureVelocity.y / yDistance : 0
        )
    }

    private func timingParameters(
        basedOn initialVelocity: CGVector
    ) -> UITimingCurveProvider {
        UISpringTimingParameters(
            dampingRatio: 1,
            initialVelocity: initialVelocity
        )
    }

    private func propertyAnimator(
        basedOn initialVelocity: CGVector
    ) -> UIViewPropertyAnimator {
        UIViewPropertyAnimator(
            duration: 2.25,
            timingParameters: timingParameters(
                basedOn: initialVelocity
            )
        )
    }

    private func makeOffsetAnimator(
        animating view: UIView,
        to offset: CGPoint,
        with initialVelocity: CGVector
    ) -> UIViewPropertyAnimator {
        let propertyAnimator = propertyAnimator(basedOn: initialVelocity)

        let originalXOffset = centerXConstraint?.constant ?? 0
        let originalYOffset = centerYConstraint?.constant ?? 0

        propertyAnimator.addAnimations {
            self.centerXConstraint?.isActive = false
            self.centerYConstraint?.isActive = false

            view.superview?.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { position in
            self.centerXConstraint?.isActive = position != .end
            self.centerXConstraint?.constant = position == .end
                ? offset.x
                : position == .current
                    ? view.center.x
                    : originalXOffset
            self.centerYConstraint?.isActive = position != .end
            self.centerYConstraint?.constant = position == .end
                ? offset.y
                : position == .current
                    ? view.center.y
                    : originalYOffset
        }

        return propertyAnimator
    }
}

extension Animator {
    func start(animating view: UIView) {
        if offsetAnimator?.state == .active {
            // The cube is in movement.

            // Stop the running offset animator in place.
            offsetAnimator?.stopAnimation(false)
            offsetAnimator?.finishAnimation(at: .current)

            initialCubeCenter = view.center
        } else {
            initialCubeCenter = view.center

            centerXConstraint?.constant = initialCubeCenter.x
            centerXConstraint?.isActive = true

            centerYConstraint?.constant = initialCubeCenter.y
            centerYConstraint?.isActive = true
        }
    }

    func move(_ view: UIView, basedOn translation: CGPoint) {
        centerXConstraint?.constant = initialCubeCenter.x + translation.x
        centerYConstraint?.constant = initialCubeCenter.y + translation.y
    }

    func stop(animating view: UIView, with velocity: CGPoint) {
        let initialVelocity = initialVelocity(
            basedOn: velocity,
            startingAt: view.center,
            endingAt: initialCubeCenter
        )

        let offsetAnimator = makeOffsetAnimator(
            animating: view,
            to: initialCubeCenter,
            with: initialVelocity
        )

        offsetAnimator.startAnimation()

        self.offsetAnimator = offsetAnimator
    }
}
