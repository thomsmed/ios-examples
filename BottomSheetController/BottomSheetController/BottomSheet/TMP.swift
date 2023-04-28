//
//  BottomSheetTransitioningDelegate.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 04/05/2022.
//

import UIKit

// MARK: BottomSheetTransitioningDelegate

final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private weak var bottomSheetPresentationController: BottomSheetPresentationController?

    var preferredSheetTopInset: CGFloat
    var preferredSheetCornerRadius: CGFloat
    var preferredSheetSizingFactor: CGFloat
    var preferredSheetBackdropColor: UIColor

    var tapToDismissEnabled: Bool = true {
        didSet {
            bottomSheetPresentationController?.tapGestureRecognizer.isEnabled = tapToDismissEnabled
        }
    }

    var panToDismissEnabled: Bool = true {
        didSet {
            bottomSheetPresentationController?.panToDismissEnabled = panToDismissEnabled
        }
    }

    init(
        preferredSheetTopInset: CGFloat,
        preferredSheetCornerRadius: CGFloat,
        preferredSheetSizingFactor: CGFloat,
        preferredSheetBackdropColor: UIColor
    ) {
        self.preferredSheetTopInset = preferredSheetTopInset
        self.preferredSheetCornerRadius = preferredSheetCornerRadius
        self.preferredSheetSizingFactor = preferredSheetSizingFactor
        self.preferredSheetBackdropColor = preferredSheetBackdropColor
        super.init()
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let bottomSheetPresentationController = BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting ?? source,
            sheetTopInset: preferredSheetTopInset,
            sheetCornerRadius: preferredSheetCornerRadius,
            sheetSizingFactor: preferredSheetSizingFactor,
            sheetBackdropColor: preferredSheetBackdropColor
        )

        bottomSheetPresentationController.tapGestureRecognizer.isEnabled = tapToDismissEnabled
        bottomSheetPresentationController.panToDismissEnabled = panToDismissEnabled

        self.bottomSheetPresentationController = bottomSheetPresentationController

        return bottomSheetPresentationController
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard
            let bottomSheetPresentationController = dismissed.presentationController as? BottomSheetPresentationController,
            bottomSheetPresentationController.bottomSheetInteractiveDismissalTransition.wantsInteractiveStart
        else {
            return nil
        }

        return bottomSheetPresentationController.bottomSheetInteractiveDismissalTransition
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        animator as? BottomSheetInteractiveDismissalTransition
    }
}

// MARK: BottomSheetPresentationController

final class BottomSheetPresentationController: UIPresentationController {

    private lazy var backdropView: UIView = {
        let view = UIView()
        view.backgroundColor = sheetBackdropColor
        view.alpha = 0
        return view
    }()

    let bottomSheetInteractiveDismissalTransition = BottomSheetInteractiveDismissalTransition()

    let sheetTopInset: CGFloat
    let sheetCornerRadius: CGFloat
    let sheetSizingFactor: CGFloat
    let sheetBackdropColor: UIColor

    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        // Enable subviews to receive touch events as expected.
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()

    var panToDismissEnabled: Bool = true

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        sheetTopInset: CGFloat,
        sheetCornerRadius: CGFloat,
        sheetSizingFactor: CGFloat,
        sheetBackdropColor: UIColor
    ) {
        self.sheetTopInset = sheetTopInset
        self.sheetCornerRadius = sheetCornerRadius
        self.sheetSizingFactor = sheetSizingFactor
        self.sheetBackdropColor = sheetBackdropColor
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    @objc private func onTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard
            let presentedView = presentedView,
            let containerView = containerView,
            !presentedView.frame.contains(gestureRecognizer.location(in: containerView))
        else {
            return
        }

        presentingViewController.dismiss(animated: true)
    }

    @objc private func onPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let presentedView = presentedView else {
            return
        }

        let translation = gestureRecognizer.translation(in: presentedView)

        let progress = translation.y / presentedView.frame.height

        switch gestureRecognizer.state {
            case .began:
                bottomSheetInteractiveDismissalTransition.start(
                    moving: presentedView, interactiveDismissal: panToDismissEnabled
                )
            case .changed:
                if panToDismissEnabled, progress > 0, !presentedViewController.isBeingDismissed {
                    presentingViewController.dismiss(animated: true)
                }
                bottomSheetInteractiveDismissalTransition.move(
                    presentedView, using: translation.y
                )
            default:
                let velocity = gestureRecognizer.velocity(in: presentedView)
                bottomSheetInteractiveDismissalTransition.stop(
                    moving: presentedView, using: translation.y, and: velocity
                )
        }
    }
}

// MARK: BottomSheetPresentationController+UIGestureRecognizerDelegate

extension BottomSheetPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Ignore new gestures while there is an ongoing transition.
        !bottomSheetInteractiveDismissalTransition.activeTransition
    }
}

// MARK: BottomSheetPresentationController+UIPresentationController

extension BottomSheetPresentationController {

    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView else {
            return
        }

        presentedView.addGestureRecognizer(panGestureRecognizer)

        presentedView.layer.cornerRadius = sheetCornerRadius
        presentedView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        presentedView.clipsToBounds = true

        guard let containerView = containerView else {
            return
        }

        containerView.addGestureRecognizer(tapGestureRecognizer)

        containerView.addSubview(backdropView)

        backdropView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(
                equalTo: containerView.topAnchor
            ),
            backdropView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            backdropView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
            backdropView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            ),
        ])

        containerView.addSubview(presentedView)

        presentedView.translatesAutoresizingMaskIntoConstraints = false

        let preferredHeightConstraint = presentedView.heightAnchor.constraint(
            equalTo: containerView.heightAnchor,
            multiplier: sheetSizingFactor
        )

        preferredHeightConstraint.priority = .fittingSizeLevel

        let topConstraint = presentedView.topAnchor.constraint(
            greaterThanOrEqualTo: containerView.safeAreaLayoutGuide.topAnchor,
            constant: sheetTopInset
        )

        // Prevents conflicts with the height constraint used by the animated transition
        topConstraint.priority = .required - 1

        let heightConstraint = presentedView.heightAnchor.constraint(
            equalToConstant: 0
        )

        let bottomConstraint = presentedView.bottomAnchor.constraint(
            equalTo: containerView.bottomAnchor
        )

        NSLayoutConstraint.activate([
            topConstraint,
            presentedView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            presentedView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
            bottomConstraint,
            preferredHeightConstraint
        ])

        bottomSheetInteractiveDismissalTransition.bottomConstraint = bottomConstraint
        bottomSheetInteractiveDismissalTransition.heightConstraint = heightConstraint

        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }

        transitionCoordinator.animate { context in
            self.backdropView.alpha = 0.3
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            backdropView.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }

        transitionCoordinator.animate { context in
            self.backdropView.alpha = 0
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backdropView.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        panGestureRecognizer.isEnabled = false // This will cancel any ongoing pan gesture
        coordinator.animate(alongsideTransition: nil) { context in
            self.panGestureRecognizer.isEnabled = true
        }
    }
}

// MARK: BottomSheetInteractiveDismissalTransition

final class BottomSheetInteractiveDismissalTransition: NSObject {
    private enum State {
        case started
        case stopping
        case stopped
    }

    private let thresholdVelocity: CGFloat = 500
    private let stretchOffset: CGFloat = 16
    private let frequencyResponse: CGFloat = 0.25 // How quickly the spring animation settles.

    private weak var transitionContext: UIViewControllerContextTransitioning?

    private var heightAnimator: UIViewPropertyAnimator?
    private var offsetAnimator: UIViewPropertyAnimator?

    private var interactiveDismissal: Bool = false

    // We'll track the different states of an ongoing dismiss transition.
    // This prevent a new dismiss transition to start before the previous has finished.
    private var state: State = .stopped

    var bottomConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?

    var activeTransition: Bool {
        state != .stopped
    }

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

    func start(moving presentedView: UIView, interactiveDismissal: Bool) {
        guard state == .stopped else {
            return
        }
        state = .started

        self.interactiveDismissal = interactiveDismissal

        heightAnimator?.stopAnimation(false)
        heightAnimator?.finishAnimation(at: .start)
        offsetAnimator?.stopAnimation(false)
        offsetAnimator?.finishAnimation(at: .start)

        heightAnimator = createHeightAnimator(
            animating: presentedView, from: presentedView.frame.height
        )

        if !interactiveDismissal {
            offsetAnimator = createOffsetAnimator(
                animating: presentedView, to: stretchOffset
            )
        }
    }

    func move(_ presentedView: UIView, using translation: CGFloat) {
        guard state == .started else {
            return
        }

        let progress = translation / presentedView.frame.height

        let stretchProgress = stretchProgress(basedOn: translation)

        heightAnimator?.fractionComplete = progress < 0
        ? -stretchProgress
        : 0
        offsetAnimator?.fractionComplete = progress > 0
        ? interactiveDismissal
        ? progress
        : stretchProgress
        : 0

        transitionContext?.updateInteractiveTransition(interactiveDismissal ? progress : 0)
    }

    func stop(moving presentedView: UIView, using translation: CGFloat, and velocity: CGPoint) {
        guard state == .started else {
            return
        }
        state = .stopping

        let progress = translation / presentedView.frame.height

        let stretchProgress = stretchProgress(basedOn: translation)

        heightAnimator?.fractionComplete = progress < 0
        ? -stretchProgress
        : 0
        offsetAnimator?.fractionComplete = progress > 0
        ? interactiveDismissal
        ? progress
        : stretchProgress
        : 0

        transitionContext?.updateInteractiveTransition(interactiveDismissal ? progress : 0)

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

                self.interactiveDismissal = false
                self.state = .stopped
            }

            heightAnimator?.continueAnimation(
                withTimingParameters: timingParameters(),
                durationFactor: 1
            )
        } else {
            guard
                let offsetAnimator,
                offsetAnimator.state == .active
            else {
                // The gesture stopped before `startInteractiveTransition(_:)` was called,
                // so there is no active `offsetAnimator`.
                heightAnimator?.stopAnimation(false)
                heightAnimator?.finishAnimation(at: .start)

                interactiveDismissal = false
                state = .stopped

                return
            }

            // There is an active `offsetAnimator`.
            // Lets resume the animator and have it run until the end (or start, if reversed).
            offsetAnimator.addCompletion { _ in
                self.heightAnimator?.stopAnimation(false)
                self.heightAnimator?.finishAnimation(at: .start)

                self.interactiveDismissal = false
                self.state = .stopped
            }

            // Tip on how to calculate initial velocity:
            // https://developer.apple.com/documentation/uikit/uispringtimingparameters/1649909-initialvelocity
            let presentedViewHeight = presentedView.frame.height
            let fractionComplete = offsetAnimator.fractionComplete

            let yDistance = cancelDismiss
            ? fractionComplete * presentedViewHeight
            : presentedViewHeight - fractionComplete * presentedViewHeight

            let initialVelocity: CGVector = .init(
                dx: 0,
                dy: yDistance != 0
                ? velocity.y / yDistance
                : 0
            )

            offsetAnimator.continueAnimation(
                withTimingParameters: timingParameters(with: initialVelocity),
                durationFactor: 1
            )
        }
    }
}

// MARK: UIViewControllerAnimatedTransitioning

extension BottomSheetInteractiveDismissalTransition: UIViewControllerAnimatedTransitioning {

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        // Build a property animator with correct timing parameters to find correct transition duration.
        propertyAnimator().duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        assertionFailure("This method should in practice never be called")

        // This method is never called since we only care about interactive transitions,
        // and use UIKit's default transitions/animations for non-interactive transitions.
        guard let presentedView = transitionContext.view(forKey: .from) else {
            return
        }

        offsetAnimator?.stopAnimation(false)
        offsetAnimator?.finishAnimation(at: .start)

        let offset = presentedView.frame.height
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
            fatalError("Somehow the animator is not set")
        }

        return offsetAnimator
    }
}

// MARK: UIViewControllerInteractiveTransitioning

extension BottomSheetInteractiveDismissalTransition: UIViewControllerInteractiveTransitioning {

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            transitionContext.isInteractive,
            let presentedView = transitionContext.view(forKey: .from)
        else {
            return animateTransition(using: transitionContext)
        }

        offsetAnimator?.stopAnimation(false)
        offsetAnimator?.finishAnimation(at: .start)

        let offset = presentedView.frame.height
        let offsetAnimator = createOffsetAnimator(animating: presentedView, to: offset)

        offsetAnimator.addCompletion { position in
            transitionContext.completeTransition(position == .end)
        }

        offsetAnimator.fractionComplete = 0

        transitionContext.updateInteractiveTransition(0)

        if state != .started {
            // The gesture driving the transition has already ended/canceled.
            // Make sure both transition context and animation is canceled.
            transitionContext.cancelInteractiveTransition()

            offsetAnimator.stopAnimation(false)
            offsetAnimator.finishAnimation(at: .start)
        }

        self.offsetAnimator = offsetAnimator
        self.transitionContext = transitionContext
    }

    var wantsInteractiveStart: Bool {
        interactiveDismissal
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
