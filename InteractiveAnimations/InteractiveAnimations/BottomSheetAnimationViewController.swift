//
//  BottomSheetAnimationViewController.swift
//  InteractiveAnimations
//
//  Created by Thomas Asheim Smedmann on 02/05/2023.
//

import UIKit

// MARK: BottomSheetView

final class BottomSheetView: UIView {
    private let handleViewHeight: CGFloat = 8

    private lazy var handleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = handleViewHeight / 2
        view.clipsToBounds = true
        return view
    }()

    init() {
        super.init(frame: .zero)

        addSubview(handleView)

        NSLayoutConstraint.activate([
            handleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            handleView.centerYAnchor.constraint(equalTo: topAnchor, constant: handleViewHeight),
            handleView.heightAnchor.constraint(equalToConstant: handleViewHeight),
            handleView.widthAnchor.constraint(equalToConstant: handleViewHeight * 10)
        ])

        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: BottomSheetAnimationViewController

final class BottomSheetAnimationViewController: UIViewController {
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Open Bottom Sheet", for: .normal)
        return button
    }()

    private lazy var bottomSheetView: UIView = {
        let bottomSheetView = BottomSheetView()
        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        return bottomSheetView
    }()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer(
            target: self, action: #selector(onPan)
        )
        gestureRecognizer.cancelsTouchesInView = false
        return gestureRecognizer
    }()

    private var animator: Animator = Animator()

    override func loadView() {
        let view = UIView()

        view.addSubview(bottomSheetView)

        let heightConstraint = bottomSheetView.heightAnchor.constraint(
            equalTo: view.heightAnchor, multiplier: 0.66
        )
        // Slightly lower the priority to prevent conflicts with the animator.
        heightConstraint.priority = .required - 1

        let bottomToTopConstraint = bottomSheetView.bottomAnchor.constraint(
            equalTo: bottomSheetView.topAnchor
        )

        let bottomConstraint = bottomSheetView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor
        )

        animator.bottomToTopConstraint = bottomToTopConstraint
        animator.bottomConstraint = bottomConstraint

        NSLayoutConstraint.activate([
            heightConstraint,
            bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
        ])

        view.backgroundColor = .systemBackground

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bottomSheetView.addGestureRecognizer(panGestureRecognizer)
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
                animator.stop(animating: view)
        }
    }
}

fileprivate final class Animator {
    var bottomToTopConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?

    private var maxStretch: CGFloat = .zero

    private var initialSheetHeight: CGFloat = .zero
    private var initialTranslation: CGPoint = .zero

    private var heightAnimator: UIViewPropertyAnimator?
    private var offsetAnimator: UIViewPropertyAnimator?

    private func timingParameters() -> UITimingCurveProvider {
        UISpringTimingParameters(
            dampingRatio: 1,
            initialVelocity: .zero
        )
    }

    private func propertyAnimator() -> UIViewPropertyAnimator {
        UIViewPropertyAnimator(
            duration: 2.25,
            timingParameters: timingParameters()
        )
    }

    private func makeHeightAnimator(
        animating view: UIView,
        to height: CGFloat
    ) -> UIViewPropertyAnimator {
        let propertyAnimator = propertyAnimator()

        let originalHeight = view.frame.height

        propertyAnimator.addAnimations {
            self.bottomToTopConstraint?.constant = height
            self.bottomToTopConstraint?.isActive = true

            view.superview?.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { position in
            self.bottomToTopConstraint?.isActive = position != .start
            self.bottomToTopConstraint?.constant = position == .end
                ? height
                : position == .current
                    ? view.frame.height
                    : originalHeight
        }

        return propertyAnimator
    }

    private func makeOffsetAnimator(
        animating view: UIView,
        to offset: CGFloat
    ) -> UIViewPropertyAnimator {
        let propertyAnimator = propertyAnimator()

        let originalOffset = bottomConstraint?.constant ?? 0
        let originalCenterY = view.center.y

        propertyAnimator.addAnimations {
            self.bottomConstraint?.constant = originalOffset + offset

            view.superview?.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { position in
            self.bottomConstraint?.constant = position == .end
                ? originalOffset + offset
                : position == .current
                    ? view.center.y - originalCenterY
                    : originalOffset
        }

        return propertyAnimator
    }
}

extension Animator {
    func start(animating view: UIView) {
        if heightAnimator?.state == .active || offsetAnimator?.state == .active {
            // The sheet is currently in movement.

            // Pause the height animator.
            heightAnimator?.pauseAnimation()
            heightAnimator?.isReversed = false

            // Pause the offset animator.
            offsetAnimator?.pauseAnimation()
            offsetAnimator?.isReversed = false

            // Calculate new initial translation.
            let heightFraction = heightAnimator?.fractionComplete ?? 0
            let offsetFraction = offsetAnimator?.fractionComplete ?? 0

            initialTranslation = CGPoint(
                x: 0,
                y: offsetFraction * initialSheetHeight - heightFraction * maxStretch
            )
        } else {
            // The sheet is currently at rest.

            maxStretch = view.frame.height / 2
            initialSheetHeight = view.frame.height
            initialTranslation = .zero

            // Create a new height animator.
            let heightAnimator = makeHeightAnimator(
                animating: view, to: initialSheetHeight + maxStretch
            )

            heightAnimator.pauseAnimation()

            self.heightAnimator = heightAnimator

            // Create a new offset animator.
            let offsetAnimator = makeOffsetAnimator(
                animating: view, to: initialSheetHeight
            )

            offsetAnimator.pauseAnimation()

            self.offsetAnimator = offsetAnimator
        }
    }

    func move(_ view: UIView, basedOn translation: CGPoint) {
        let totalTranslationY = initialTranslation.y + translation.y

        let heightFraction = min(
            abs(min(totalTranslationY, 0)) / maxStretch, 1
        )

        let offsetFraction = min(
            max(totalTranslationY, 0) / initialSheetHeight, 1
        )

        heightAnimator?.fractionComplete = heightFraction

        offsetAnimator?.fractionComplete = offsetFraction
    }

    func stop(animating view: UIView) {
        // TODO: Use velocity to adjust timing parameters

        offsetAnimator?.isReversed = offsetAnimator?.fractionComplete ?? 0 < 0.5

        offsetAnimator?.continueAnimation(
            withTimingParameters: timingParameters(),
            durationFactor: 1
        )

        heightAnimator?.isReversed = true

        heightAnimator?.continueAnimation(
            withTimingParameters: timingParameters(),
            durationFactor: 1
        )
    }
}
