//
//  BottomSheetInteractiveDismissalTransition.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 28/04/2023.
//

import UIKit

final class BottomSheetInteractiveDismissalTransition: NSObject {

    private let stretchHeight: CGFloat

    // Points per seconds. Just a number that felt "natural".
    // Used as threshold for triggering dismissal.
    private let dismissalVelocityThreshold: CGFloat = 2000

    // "Distance" per seconds. Just a number that felt "natural" and prevents
    // too much overshoot when defining spring parameters with initial velocity.
    private let maxInitialVelocity: CGFloat = 20

    // How quickly the spring animation settles.
    private let springAnimationSettlingTime: CGFloat = 0.33

    private weak var transitionContext: UIViewControllerContextTransitioning?

    private var heightAnimator: UIViewPropertyAnimator?
    private var offsetAnimator: UIViewPropertyAnimator?

    // Capture the sheet's initial height.
    private var initialSheetHeight: CGFloat = .zero

    // This tracks the how far the sheet has initially moved at the start of a gesture.
    // The sheet can be in movement/mid-animation when a gesture happens.
    private var initialTranslation: CGPoint = .zero

    private(set) var interactiveDismissal: Bool = false

    var heightConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?

    init(stretchOffset: CGFloat) {
        self.stretchHeight = stretchOffset
    }

    private func initialVelocity(
        basedOn gestureVelocity: CGPoint,
        startingAt currentValue: CGFloat,
        endingAt finalValue: CGFloat
    ) -> CGVector {
        // Tip on how to calculate initial velocity:
        // https://developer.apple.com/documentation/uikit/uispringtimingparameters/1649909-initialvelocity
        let distance = finalValue - currentValue

        var velocity: CGFloat = 0

        if distance != 0 {
            velocity = gestureVelocity.y / distance
        }

        // Limit the velocity to prevent too much overshoot if the velocity is high.
        if velocity > 0 {
            velocity = min(velocity, maxInitialVelocity)
        } else {
            velocity = max(velocity, -maxInitialVelocity)
        }

        return CGVector(dx: velocity, dy: velocity)
    }

    private func timingParameters(
        with initialVelocity: CGVector = .zero
    ) -> UITimingCurveProvider {
        UISpringTimingParameters(
            dampingRatio: 1,
            initialVelocity: initialVelocity
        )
    }

    private func propertyAnimator(
        with initialVelocity: CGVector = .zero
    ) -> UIViewPropertyAnimator {
        UIViewPropertyAnimator(
            duration: springAnimationSettlingTime,
            timingParameters: timingParameters(
                with: initialVelocity
            )
        )
    }

    private func makeHeightAnimator(
        animating view: UIView,
        to height: CGFloat,
        _ completion: @escaping (UIViewAnimatingPosition) -> Void
    ) -> UIViewPropertyAnimator {
        let propertyAnimator = propertyAnimator()

        // Make sure layout is up to date before adding animations.
        view.superview?.layoutIfNeeded()

        let originalHeight = view.frame.height

        propertyAnimator.addAnimations {
            self.heightConstraint?.constant = height
            self.heightConstraint?.isActive = true

            view.superview?.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { position in
            self.heightConstraint?.isActive = position != .start
            self.heightConstraint?.constant = position == .end
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

        // Make sure layout is up to date before adding animations.
        view.superview?.layoutIfNeeded()

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

    private func updateHeightAnimator(
        animating view: UIView,
        with fractionComplete: CGFloat
    ) {
        // Cancel any running offset animator so it does not interfere with the height animator.
        offsetAnimator?.stopAnimation(false)
        offsetAnimator?.finishAnimation(at: .start)

        self.offsetAnimator = nil

        let heightAnimator = self.heightAnimator ?? makeHeightAnimator(
            animating: view, to: initialSheetHeight + stretchHeight
        ) { _ in
            // Throw away the used animator, so we are ready to start fresh.
            self.heightAnimator = nil
        }

        heightAnimator.fractionComplete = fractionComplete

        self.heightAnimator = heightAnimator
    }

    private func updateOffsetAnimator(
        animating view: UIView,
        with fractionComplete: CGFloat
    ) {
        // Cancel any running height animator so it does not interfere with the offset animator.
        heightAnimator?.stopAnimation(false)
        heightAnimator?.finishAnimation(at: .start)

        self.heightAnimator = nil

        defer {
            offsetAnimator?.fractionComplete = fractionComplete

            // Update any active transition context.
            transitionContext?.updateInteractiveTransition(fractionComplete)
        }

        // Return early and leave the creation of the offset animator to
        // our implementation of `UIViewControllerInteractiveTransitioning`
        // if this is an interactive dismissal.
        if interactiveDismissal {
            return
        }

        let offsetAnimator = self.offsetAnimator ?? makeOffsetAnimator(
            animating: view, to: stretchHeight
        ) { position in
            // Throw away the used animator, so we are ready to start fresh.
            self.offsetAnimator = nil
        }

        self.offsetAnimator = offsetAnimator
    }

    private func checkIfPotentialDismissalAndUpdateAnimators(
        animating view: UIView,
        using translation: CGPoint
    ) -> Bool {
        // Figure out how far the sheet has moved away from its original position.
        let totalTranslationY = initialTranslation.y + translation.y

        // Since we animate the same properties in both animators (size and position),
        // we avoid conflicts by only running one animator at the time.
        if totalTranslationY < 0 {
            // The sheet wants to move above its original height.
            // Make (or use an already running) height animator to drive this movement.

            // Figure out the height animator's fraction complete.
            // Using `pow()` to add a rubber band effect.
            let heightFraction = min(pow(abs(min(totalTranslationY, 0)), 0.5) / stretchHeight, 1)

            updateHeightAnimator(
                animating: view,
                with: heightFraction
            )
        } else {
            // The sheet wants to move below its original height.
            // Make (or use an already running) offset animator to drive this movement.

            // Figure out the offset animator's fraction complete.
            // Using `pow()` to add a rubber band effect (when non-interactive dismissal).
            let offsetFraction: CGFloat
            if interactiveDismissal {
                offsetFraction = min(max(totalTranslationY, 0) / initialSheetHeight, 1)
            } else {
                offsetFraction = min(pow(max(totalTranslationY, 0), 0.5) / stretchHeight, 1)
            }

            updateOffsetAnimator(
                animating: view,
                with: offsetFraction
            )
        }

        // Signal that the sheet is moving towards dismissal.
        return interactiveDismissal && totalTranslationY > 0
    }
}

// MARK: Public methods

extension BottomSheetInteractiveDismissalTransition {

    func cancel() {
        // Cancels any active animators (`.stopAnimation(false)`
        // and leave the animated properties at current value (`finishAnimation(at: .current)`).
        heightAnimator?.stopAnimation(false)
        heightAnimator?.finishAnimation(at: .current)
        offsetAnimator?.stopAnimation(false)
        offsetAnimator?.finishAnimation(at: .current)
    }

    func checkIfPotentialDismissalAndStart(
        moving presentedView: UIView,
        using translation: CGPoint,
        asInteractiveDismissal interactiveDismissal: Bool
    ) -> Bool {
        // Capture interactive dismissal control flag.
        self.interactiveDismissal = interactiveDismissal

        if heightAnimator?.state == .active || offsetAnimator?.state == .active {
            // The sheet is currently in movement.

            // Pause the height animator (if present).
            heightAnimator?.pauseAnimation()
            heightAnimator?.isReversed = false

            // Pause the offset animator (if present).
            offsetAnimator?.pauseAnimation()
            offsetAnimator?.isReversed = false

            // Pause any active transition context.
            transitionContext?.pauseInteractiveTransition()

            // Calculate new initial translation.
            let heightFraction = heightAnimator?.fractionComplete ?? 0
            let offsetFraction = offsetAnimator?.fractionComplete ?? 0

            let finalOffset = interactiveDismissal ? initialSheetHeight : stretchHeight

            initialTranslation = CGPoint(
                x: 0,
                y: offsetFraction * finalOffset - heightFraction * stretchHeight
            )

            // How far the sheet has moved away from its original position.
            let totalTranslationY = initialTranslation.y + translation.y

            // Signal that the sheet is moving towards dismissal.
            return interactiveDismissal && totalTranslationY > 0
        } else {
            // The sheet is currently at rest.

            // Capture control values.
            presentedView.superview?.layoutIfNeeded()

            initialSheetHeight = presentedView.frame.height
            initialTranslation = .zero

            return checkIfPotentialDismissalAndUpdateAnimators(
                animating: presentedView, using: translation
            )
        }
    }

    func checkIfPotentialDismissalAndMove(
        _ presentedView: UIView,
        using translation: CGPoint
    ) -> Bool {
        checkIfPotentialDismissalAndUpdateAnimators(
            animating: presentedView, using: translation
        )
    }

    func stop(
        moving presentedView: UIView,
        with velocity: CGPoint
    ) {
        if let heightAnimator {
            let fractionComplete = heightAnimator.fractionComplete

            let initialHeightVelocity = initialVelocity(
                basedOn: velocity,
                startingAt: fractionComplete * stretchHeight,
                endingAt: stretchHeight
            )

            // Always animate back to initial sheet height.
            heightAnimator.isReversed = true

            heightAnimator.continueAnimation(
                withTimingParameters: timingParameters(
                    with: initialHeightVelocity
                ),
                durationFactor: 1
            )
        } else if let offsetAnimator {
            let fractionComplete = offsetAnimator.fractionComplete

            // Determine if the dismissal should continue (and animate the sheet off screen),
            // or if it should be canceled (and the animation reversed).
            let continueDismissal = interactiveDismissal && // Needs to be interactive dismissal.
            (
                velocity.y > dismissalVelocityThreshold || // Gesture velocity is more than the threshold.
                fractionComplete > 0.5 && velocity.y > -dismissalVelocityThreshold // The sheet is 50% off screen and the gesture velocity is greater than the negative threshold.
            )

            let initialOffsetVelocity = initialVelocity(
                basedOn: velocity,
                startingAt: fractionComplete * initialSheetHeight,
                endingAt: continueDismissal ? initialSheetHeight : 0
            )

            offsetAnimator.isReversed = !continueDismissal

            // Update any active transition context.
            if continueDismissal {
                transitionContext?.finishInteractiveTransition()
            } else {
                transitionContext?.cancelInteractiveTransition()
            }

            offsetAnimator.continueAnimation(
                withTimingParameters: timingParameters(
                    with: initialOffsetVelocity
                ),
                durationFactor: 1
            )
        } else {
            // We are only allowed to end up here if this is an interactive dismissal.
            // E.g `UIViewControllerInteractiveTransitioning.startInteractiveTransition(_:)` has not yet been called (and hence no offset animator exist yet).
            // If this is a non-interactive dismissal we'd expect one of the animators (height or offset) to always exist.
            assert(interactiveDismissal)
        }

        // Reset any previously set interactive dismissal control flag.
        interactiveDismissal = false
    }
}

// MARK: UIViewControllerAnimatedTransitioning

extension BottomSheetInteractiveDismissalTransition: UIViewControllerAnimatedTransitioning {

    private func doDismissTransitionWithoutAnimation() {
        bottomConstraint?.constant += initialSheetHeight
    }

    private func prepareOffsetAnimatorForDismissTransition(
        animating view: UIView,
        associatedWith transitionContext: UIViewControllerContextTransitioning
    ) {
        // Cancel any running height animator so it does not interfere with the offset animator.
        heightAnimator?.stopAnimation(false)
        heightAnimator?.finishAnimation(at: .start)

        heightAnimator = nil

        // We expect there to be no other active offset animator
        // before this point when dismissing interactively.
        assert(offsetAnimator == nil)

        let offsetAnimator = makeOffsetAnimator(
            animating: view, to: initialSheetHeight
        ) { position in
            // Throw away the used animator, so we are ready to start fresh.
            self.offsetAnimator = nil

            // Also remove reference to the transition context.
            self.transitionContext = nil

            transitionContext.completeTransition(position == .end)
        }

        self.offsetAnimator = offsetAnimator
        self.transitionContext = transitionContext
    }

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
            return doDismissTransitionWithoutAnimation()
        }

        prepareOffsetAnimatorForDismissTransition(
            animating: presentedView, associatedWith: transitionContext
        )

        transitionContext.finishInteractiveTransition()

        offsetAnimator?.startAnimation()
    }

    func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        // At this point `UIViewControllerInteractiveTransitioning.startInteractiveTransition(_:)`
        // should have been called and there should exist a newly created offset animator.
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

        prepareOffsetAnimatorForDismissTransition(
            animating: presentedView, associatedWith: transitionContext
        )

        transitionContext.pauseInteractiveTransition()

        offsetAnimator?.pauseAnimation()

        if !interactiveDismissal {
            // The gesture driving the transition has already ended or been canceled.
            // Make sure both transition context and animation is canceled.
            transitionContext.cancelInteractiveTransition()

            self.offsetAnimator?.isReversed = true

            self.offsetAnimator?.continueAnimation(
                withTimingParameters: timingParameters(),
                durationFactor: 1
            )
        }
    }
}
