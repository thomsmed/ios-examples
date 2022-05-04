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

    var preferredSheetSizingFactor: CGFloat

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

    init(preferredSheetSizingFactor: CGFloat) {
        self.preferredSheetSizingFactor = preferredSheetSizingFactor
        super.init()
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let bottomSheetPresentationController = BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting ?? source
        )
        bottomSheetPresentationController.sheetSizingFactor = preferredSheetSizingFactor
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

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()

    let bottomSheetInteractiveTransition = BottomSheetInteractiveTransition()

    var sheetSizingFactor: CGFloat = 1

    lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
    lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan))

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
            bottomSheetInteractiveTransition.update(progress)
            presentedViewController.dismiss(animated: true)
        case .changed:
            bottomSheetInteractiveTransition.update(progress)
        case .ended, .cancelled:
            let velocity = gestureRecognizer.velocity(in: presentedView)
            if progress > 0.5 && velocity.y > 0 {
                bottomSheetInteractiveTransition.finish()
            } else {
                bottomSheetInteractiveTransition.cancel()
            }
        default:
            return
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
        let absoluteMaxHeight = containerViewFrame.height - containerView.safeAreaInsets.top - 24
        let preferredMaxHeight = absoluteMaxHeight * sheetSizingFactor

        let fittingSize = presentedView.systemLayoutSizeFitting(
            .init(width: containerViewFrame.width, height: preferredMaxHeight),
            withHorizontalFittingPriority: .fittingSizeLevel,
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

        presentedView.layer.cornerRadius = 10
        presentedView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]

        guard let containerView = containerView else {
            return
        }

        containerView.addGestureRecognizer(tapGestureRecognizer)

        containerView.addSubview(backgroundView)

        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        backgroundView.layoutIfNeeded()

        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }

        transitionCoordinator.animate() { context in
            self.backgroundView.alpha = 0.3
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            backgroundView.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }

        transitionCoordinator.animate(alongsideTransition: { context in
            self.backgroundView.alpha = 0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backgroundView.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        backgroundView.layoutIfNeeded()

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

    private(set) var interactiveDismissal: Bool = false

    override func update(_ percentComplete: CGFloat) {
        super.update(percentComplete)

        interactiveDismissal = true
    }

    override func cancel() {
        super.cancel()

        interactiveDismissal = false
    }

    override func finish() {
        super.finish()

        interactiveDismissal = false
    }
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
