//
//  BottomSheetInteractiveDismissalTransition.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 28/04/2023.
//

import UIKit

final class BottomSheetInteractiveDismissalTransition: NSObject {

    private let thresholdVelocity: CGFloat = 500
    private let stretchOffset: CGFloat = 16
    private let frequencyResponse: CGFloat = 0.25 // How quickly the spring animation settles.

    private weak var transitionContext: UIViewControllerContextTransitioning?

    private var heightAnimator: UIViewPropertyAnimator?
    private var offsetAnimator: UIViewPropertyAnimator?

    private var presentedViewHeight: CGFloat = .zero

    private(set) var interactiveDismissal: Bool = false

    var bottomConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?

    private func timingParameters(
        with initialVelocity: CGVector = .zero
    ) -> UISpringTimingParameters {
        // Tip on how to calculate initial velocity:
        // https://developer.apple.com/documentation/uikit/uispringtimingparameters/1649909-initialvelocity
        UISpringTimingParameters(
            dampingRatio: 1,
            frequencyResponse: frequencyResponse,
            initialVelocity: initialVelocity
        )
    }

    private func propertyAnimator(
        with initialVelocity: CGVector = .zero
    ) -> UIViewPropertyAnimator {
        UIViewPropertyAnimator(
            duration: frequencyResponse, // Ignored since we use `UISpringTimingParameters`.
            timingParameters: timingParameters(with: initialVelocity)
        )
    }

    private func createHeightAnimator(
        animating view: UIView,
        from height: CGFloat
    ) -> UIViewPropertyAnimator {
        heightConstraint?.constant = height
        heightConstraint?.isActive = true

        let finalHeight = height + stretchOffset

        let propertyAnimator = propertyAnimator()
        propertyAnimator.addAnimations {
            self.heightConstraint?.constant = finalHeight
            view.superview?.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { position in
            self.heightConstraint?.isActive = position == .end ? true : false
            self.heightConstraint?.constant = position == .end ? finalHeight : height
        }

        return propertyAnimator
    }

    private func createOffsetAnimator(
        animating view: UIView,
        to offset: CGFloat
    ) -> UIViewPropertyAnimator {
        let propertyAnimator = propertyAnimator()
        propertyAnimator.addAnimations {
            self.bottomConstraint?.constant = offset
            view.superview?.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { position in
            self.bottomConstraint?.constant = position == .end ? offset : 0
        }

        return propertyAnimator
    }

    private func stretchProgress(basedOn translation: CGFloat) -> CGFloat {
        (translation > 0 ? pow(translation, 0.33) : -pow(-translation, 0.33)) / stretchOffset
    }
}

// MARK: Public methods

extension BottomSheetInteractiveDismissalTransition {

    func cancel() {
        heightAnimator?.stopAnimation(false)
        heightAnimator?.finishAnimation(at: .start)
        offsetAnimator?.stopAnimation(false)
        offsetAnimator?.finishAnimation(at: .start)
    }

    func start(
        moving presentedView: UIView,
        interactiveDismissal: Bool
    ) {
        self.interactiveDismissal = interactiveDismissal

        cancel()

        presentedViewHeight = presentedView.frame.height

        heightAnimator = createHeightAnimator(
            animating: presentedView, from: presentedViewHeight
        )

        if !interactiveDismissal {
            offsetAnimator = createOffsetAnimator(
                animating: presentedView, to: stretchOffset
            )
        }
    }

    func move(
        _ presentedView: UIView,
        using translation: CGFloat
    ) {
        let progress = translation / presentedViewHeight

        let stretchProgress = stretchProgress(basedOn: translation)

        heightAnimator?.fractionComplete = stretchProgress * -1
        offsetAnimator?.fractionComplete = interactiveDismissal ? progress : stretchProgress

        transitionContext?.updateInteractiveTransition(progress)
    }

    func stop(
        moving presentedView: UIView,
        using translation: CGFloat,
        and velocity: CGPoint
    ) {
        let progress = translation / presentedViewHeight

        let stretchProgress = stretchProgress(basedOn: translation)

        heightAnimator?.fractionComplete = stretchProgress * -1
        offsetAnimator?.fractionComplete = interactiveDismissal ? progress : stretchProgress

        transitionContext?.updateInteractiveTransition(progress)

        let cancelDismiss = !interactiveDismissal ||
                            velocity.y < thresholdVelocity ||
                            (progress < 0.5 && velocity.y <= 0)

        heightAnimator?.isReversed = true
        offsetAnimator?.isReversed = cancelDismiss

        if cancelDismiss {
            transitionContext?.cancelInteractiveTransition()
        } else {
            transitionContext?.finishInteractiveTransition()
        }

        if progress < 0 {
            heightAnimator?.addCompletion { _ in
                self.offsetAnimator?.stopAnimation(false)
                self.offsetAnimator?.finishAnimation(at: .start)
            }

            heightAnimator?.continueAnimation(
                withTimingParameters: timingParameters(),
                durationFactor: 1
            )
        } else {
            offsetAnimator?.addCompletion { _ in
                self.heightAnimator?.stopAnimation(false)
                self.heightAnimator?.finishAnimation(at: .start)
            }

            offsetAnimator?.continueAnimation(
                withTimingParameters: timingParameters(),
                durationFactor: 1
            )
        }

        interactiveDismissal = false
    }
}

// MARK: UIViewControllerAnimatedTransitioning

extension BottomSheetInteractiveDismissalTransition: UIViewControllerAnimatedTransitioning {

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        // This value is not really used since we only care about interactive transitions.
        propertyAnimator().duration
    }

    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        // This is never really called since we only care about interactive transitions,
        // and use UIKit's default transitions/animations for non-interactive transitions.
        guard
            transitionContext.isAnimated,
            let presentedView = transitionContext.view(forKey: .from)
        else {
            return
        }

        offsetAnimator?.stopAnimation(true)

        let offset = presentedViewHeight
        let offsetAnimator = createOffsetAnimator(animating: presentedView, to: offset)

        offsetAnimator.addCompletion { position in
            transitionContext.completeTransition(position == .end)
        }

        offsetAnimator.startAnimation()

        self.offsetAnimator = offsetAnimator
    }

    func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        guard let offsetAnimator = offsetAnimator else {
            fatalError("Somehow the offset animator was not set")
        }

        return offsetAnimator
    }
}

// MARK: UIViewControllerInteractiveTransitioning

extension BottomSheetInteractiveDismissalTransition: UIViewControllerInteractiveTransitioning {

    var wantsInteractiveStart: Bool {
        interactiveDismissal
    }

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            transitionContext.isInteractive,
            let presentedView = transitionContext.view(forKey: .from)
        else {
            return animateTransition(using: transitionContext)
        }

        offsetAnimator?.stopAnimation(true)

        let offset = presentedViewHeight
        let offsetAnimator = createOffsetAnimator(animating: presentedView, to: offset)

        offsetAnimator.addCompletion { position in
            transitionContext.completeTransition(position == .end)
        }

        offsetAnimator.fractionComplete = 0

        transitionContext.updateInteractiveTransition(0)

        self.offsetAnimator = offsetAnimator
        self.transitionContext = transitionContext

        if !interactiveDismissal {
            // The gesture driving the transition has already ended or been canceled.
            // Make sure both transition context and animation is canceled.
            transitionContext.cancelInteractiveTransition()

            cancel()
        }
    }
}

private extension UISpringTimingParameters {
    // Utility initializer based on this awesome article by Christian Schnorr:
    // https://medium.com/ios-os-x-development/demystifying-uikit-spring-animations-2bb868446773
    convenience init(
        dampingRatio: CGFloat,
        frequencyResponse: CGFloat,
        initialVelocity: CGVector = .zero
    ) {
        precondition(dampingRatio >= 0)
        precondition(frequencyResponse > 0)

        let mass: CGFloat = 1
        let stiffness = pow(2 * .pi / frequencyResponse, 2) * mass
        let damping = 4 * .pi * dampingRatio * mass / frequencyResponse

        self.init(
            mass: mass,
            stiffness: stiffness,
            damping: damping,
            initialVelocity: initialVelocity
        )
    }
}
