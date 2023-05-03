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
    private lazy var toggleSheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reset Sheet", for: .normal)
        button.addTarget(self, action: #selector(onTap), for: .primaryActionTriggered)
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

        view.addSubview(toggleSheetButton)

        NSLayoutConstraint.activate([
            toggleSheetButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            toggleSheetButton.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32
            )
        ])

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
    private func onTap(_ button: UIButton) {
        // Reset sheet constraints.
        animator.bottomConstraint?.constant = 0
        animator.bottomToTopConstraint?.isActive = false
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
    var bottomToTopConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?

    private var maxStretch: CGFloat = .zero

    // Capture the sheet's initial height.
    private var initialSheetHeight: CGFloat = .zero

    // This tracks the how far the sheet has initially moved at the start of a gesture.
    // The sheet can be in movement/mid-animation when a gesture happens.
    private var initialTranslation: CGPoint = .zero

    private var heightAnimator: UIViewPropertyAnimator?
    private var offsetAnimator: UIViewPropertyAnimator?

    private func initialVelocity(
        basedOn gestureVelocity: CGPoint,
        startingAt currentValue: CGFloat,
        endingAt finalValue: CGFloat
    ) -> CGVector {
        // Tip on how to calculate initial velocity:
        // https://developer.apple.com/documentation/uikit/uispringtimingparameters/1649909-initialvelocity
        let distance = finalValue - currentValue

        return CGVector(
            dx: distance != 0 ? gestureVelocity.y / distance : 0,
            dy: distance != 0 ? gestureVelocity.y / distance : 0
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
        basedOn initialVelocity: CGVector = .zero
    ) -> UIViewPropertyAnimator {
        UIViewPropertyAnimator(
            duration: 2.25,
            timingParameters: timingParameters(
                basedOn: initialVelocity
            )
        )
    }

    private func makeHeightAnimator(
        animating view: UIView,
        to height: CGFloat,
        _ completion: @escaping (UIViewAnimatingPosition) -> Void
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

        propertyAnimator.addCompletion(completion)

        return propertyAnimator
    }

    private func makeOffsetAnimator(
        animating view: UIView,
        to offset: CGFloat,
        _ completion: @escaping (UIViewAnimatingPosition) -> Void
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

        propertyAnimator.addCompletion(completion)

        return propertyAnimator
    }
}

extension Animator {
    func start(animating view: UIView) {
        if heightAnimator?.state == .active || offsetAnimator?.state == .active {
            // The sheet is currently in movement.

            // Pause the height animator (if present).
            heightAnimator?.pauseAnimation()
            heightAnimator?.isReversed = false

            // Pause the offset animator (if present.
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

            // Capture control values.
            maxStretch = view.frame.height / 3
            initialSheetHeight = view.frame.height
            initialTranslation = .zero
        }
    }

    func move(_ view: UIView, basedOn translation: CGPoint) {
        // Figure out how far the sheet has moved away from its original position.
        let totalTranslationY = initialTranslation.y + translation.y

        let heightFraction = min(
            abs(min(totalTranslationY, 0)) / maxStretch, 1
        )

        let offsetFraction = min(
            max(totalTranslationY, 0) / initialSheetHeight, 1
        )

        // Since we animate the same properties in both animators (size and position),
        // we avoid conflicts by only running one at the time.
        if heightFraction > 0 {
            // The sheet wants to move above its original height.
            // Make - or use an already running - height animator to drive this movement.

            // Cancel any running offset animator so it does not interfere with the height animator.
            offsetAnimator?.stopAnimation(false)
            offsetAnimator?.finishAnimation(at: .start)

            let heightAnimator = self.heightAnimator ?? makeHeightAnimator(
                animating: view, to: initialSheetHeight + maxStretch
            ) { _ in
                // Throw away the used animator, so we are ready to start fresh.
                self.heightAnimator = nil
            }

            heightAnimator.fractionComplete = heightFraction

            self.heightAnimator = heightAnimator
        } else {
            // The sheet wants to move below its original height.
            // Make - or use an already running - offset animator to drive this movement.

            // Cancel any running height animator so it does not interfere with the offset animator.
            heightAnimator?.stopAnimation(false)
            heightAnimator?.finishAnimation(at: .start)

            let offsetAnimator = self.offsetAnimator ?? makeOffsetAnimator(
                animating: view, to: initialSheetHeight
            ) { position in
                // Throw away the used animator, so we are ready to start fresh.
                self.offsetAnimator = nil
            }

            offsetAnimator.fractionComplete = offsetFraction

            self.offsetAnimator = offsetAnimator
        }
    }

    func stop(animating view: UIView, with velocity: CGPoint) {
        if let heightAnimator {
            let fractionComplete = heightAnimator.fractionComplete

            let initialHeightVelocity = initialVelocity(
                basedOn: velocity,
                startingAt: fractionComplete * maxStretch,
                endingAt: maxStretch
            )

            // Always animate back to initial sheet height.
            heightAnimator.isReversed = true

            heightAnimator.continueAnimation(
                withTimingParameters: timingParameters(
                    basedOn: initialHeightVelocity
                ),
                durationFactor: 1
            )
        } else if let offsetAnimator {
            let fractionComplete = offsetAnimator.fractionComplete

            // Reverse the animation of the sheet is not half way off the screen.
            let reverseAnimation = fractionComplete < 0.5

            let initialOffsetVelocity = initialVelocity(
                basedOn: velocity,
                startingAt: reverseAnimation ? fractionComplete * initialSheetHeight : 0,
                endingAt: reverseAnimation ? 0 : initialSheetHeight
            )

            offsetAnimator.isReversed = reverseAnimation

            offsetAnimator.continueAnimation(
                withTimingParameters: timingParameters(
                    basedOn: initialOffsetVelocity
                ),
                durationFactor: 1
            )
        }
    }
}
