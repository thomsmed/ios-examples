//
//  BottomSheetTransitioningDelegate.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 04/05/2022.
//

import Foundation
import UIKit

// MARK: BottomSheetTransitioningDelegate

final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private weak var currentBottomSheetPresentationController: BottomSheetPresentationController?

    var preferredSheetTopInset: CGFloat
    var preferredSheetCornerRadius: CGFloat
    var preferredSheetSizingFactor: CGFloat
    var preferredSheetBackdropColor: UIColor

    var tapToDismissEnabled: Bool = true {
        didSet {
            currentBottomSheetPresentationController?.tapGestureRecognizer.isEnabled = tapToDismissEnabled
        }
    }

    var panToDismissEnabled: Bool = true {
        didSet {
            currentBottomSheetPresentationController?.panGestureRecognizer.isEnabled = panToDismissEnabled
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
        bottomSheetPresentationController.panGestureRecognizer.isEnabled = panToDismissEnabled

        currentBottomSheetPresentationController = bottomSheetPresentationController

        return bottomSheetPresentationController
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let bottomSheetPresentationController = dismissed.presentationController as? BottomSheetPresentationController else {
            return nil
        }

        return bottomSheetPresentationController.bottomSheetInteractiveTransition
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        guard let bottomSheetInteractiveTransition = animator as? BottomSheetInteractiveTransition else {
            return nil
        }

        if bottomSheetInteractiveTransition.interactiveDismissal {
            return bottomSheetInteractiveTransition
        }

        return nil
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

    let bottomSheetInteractiveTransition = BottomSheetInteractiveTransition()

    let sheetTopInset: CGFloat
    let sheetCornerRadius: CGFloat
    let sheetSizingFactor: CGFloat
    let sheetBackdropColor: UIColor

    lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
    lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan))

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

        presentedViewController.dismiss(animated: true)
    }

    @objc private func onPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let presentedView = presentedView else {
            return
        }

        let translation = gestureRecognizer.translation(in: presentedView)

        let progress = min(max(translation.y / presentedView.frame.height, 0), 1)

        switch gestureRecognizer.state {
        case .began:
            bottomSheetInteractiveTransition.interactiveDismissal = true
            presentedViewController.dismiss(animated: true)
        case .changed:
            bottomSheetInteractiveTransition.update(progress)
        default:
            let velocity = gestureRecognizer.velocity(in: presentedView)
            if (progress > 0.5 && velocity.y > 0) || velocity.y > presentedView.frame.height {
                bottomSheetInteractiveTransition.finish()
            } else {
                bottomSheetInteractiveTransition.cancel()
            }
            bottomSheetInteractiveTransition.interactiveDismissal = false
        }
    }

    // MARK: UIPresentationController

    override var frameOfPresentedViewInContainerView: CGRect {
        guard
            let containerView = containerView,
            let presentedView = presentedView
        else {
            return .zero
        }

        let containerViewFrame = containerView.frame
        let absoluteMaxHeight = containerViewFrame.height - containerView.safeAreaInsets.top - sheetTopInset
        let preferredMaxHeight = absoluteMaxHeight * sheetSizingFactor

        let fittingSize = presentedView.systemLayoutSizeFitting(
            .init(width: containerViewFrame.width, height: preferredMaxHeight),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let size: CGSize
        let origin: CGPoint

        if fittingSize.height > absoluteMaxHeight {
            size = .init(
                width: containerViewFrame.width,
                height: absoluteMaxHeight
            )
            origin = .init(
                x: containerViewFrame.minX,
                y: containerViewFrame.maxY - absoluteMaxHeight
            )
        } else {
            size = .init(
                width: containerViewFrame.width,
                height: fittingSize.height
            )
            origin = .init(
                x: containerViewFrame.minX,
                y: containerViewFrame.maxY - fittingSize.height
            )
        }

        return CGRect(origin: origin, size: size)
    }

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

        guard let containerView = containerView else {
            return
        }

        containerView.addGestureRecognizer(tapGestureRecognizer)

        containerView.addSubview(backdropView)

        backdropView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backdropView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backdropView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        backdropView.layoutIfNeeded()

        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }

        transitionCoordinator.animate() { context in
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

        transitionCoordinator.animate(alongsideTransition: { context in
            self.backdropView.alpha = 0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backdropView.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        backdropView.layoutIfNeeded()

        guard let presentedView = presentedView else {
            return
        }

        coordinator.animate() { context in
            presentedView.frame = self.frameOfPresentedViewInContainerView
        }
    }
}

// MARK: BottomSheetInteractiveTransition

final class BottomSheetInteractiveTransition: UIPercentDrivenInteractiveTransition {

    var interactiveDismissal: Bool = false
}

extension BottomSheetInteractiveTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            return
        }

        transitionContext.containerView.addSubview(fromView)

        let offset = fromView.frame.height

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                fromView.center.y += offset
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }

    func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        let propertyAnimator = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            curve: .easeInOut
        )
        propertyAnimator.addCompletion() { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        guard let fromView = transitionContext.view(forKey: .from) else {
            return propertyAnimator
        }

        transitionContext.containerView.addSubview(fromView)

        let offset = fromView.frame.height

        propertyAnimator.addAnimations {
            fromView.center.y += offset
        }

        return propertyAnimator
    }
}
