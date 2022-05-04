//
//  ShelfTransitionManager.swift
//  CustomPresentationController
//
//  Created by Thomas Asheim Smedmann on 05/11/2021.
//

import UIKit

// MARK: ShelfPresentationController

final class ShelfPresentationController: UIPresentationController {
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan))
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
    
    let shelfDismissAnimationController = ShelfDismissAnimationController()
    
    @objc private func onPan(_ gesture: UIPanGestureRecognizer) {
        guard let presentedView = presentedView else { return }
        let translation = gesture.translation(in: presentedView)
        let progress = min(max(translation.y / presentedView.frame.height, 0), 1)
        switch gesture.state {
        case .began:
            shelfDismissAnimationController.update(progress)
            presentedViewController.dismiss(animated: true)
        case .changed:
            shelfDismissAnimationController.update(progress)
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: presentedView)
            if progress > 0.5 && velocity.y > 0 {
                shelfDismissAnimationController.finish()
            } else {
                shelfDismissAnimationController.cancel()
            }
        default:
            return
        }
    }
    
    @objc private func onTap(_ gesture: UITapGestureRecognizer) {
        guard
            let presentedView = presentedView,
            let containerView = containerView,
            !presentedView.frame.contains(gesture.location(in: containerView))
        else { return }
        
        presentedViewController.dismiss(animated: true)
    }
}

// MARK: UIPresentationController

extension ShelfPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let frame = containerView.frame
        let height = containerView.frame.height / 2
        return CGRect(x: frame.minX, y: frame.minY + height, width: frame.width, height: height)
    }
    
    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView else { return }
        
        presentedView.addGestureRecognizer(panGestureRecognizer)
        
        presentedView.layer.cornerRadius = 10
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView.layer.shadowColor = UIColor.black.cgColor
        presentedView.layer.shadowOffset = .zero
        presentedView.layer.shadowOpacity = 0.3
        presentedView.layer.shadowRadius = 10
        presentedView.clipsToBounds = false
        
        guard let containerView = containerView else { return }
        
        containerView.addGestureRecognizer(tapGestureRecognizer)
        
        containerView.addSubview(backgroundView)
        backgroundView.frame = containerView.frame
        
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }
        
        transitionCoordinator.animate(alongsideTransition: { context in
            self.backgroundView.alpha = 0.3
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            backgroundView.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }
        
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
        guard
            let containerView = containerView,
            let presentedView = presentedView
        else { return }
        coordinator.animate(alongsideTransition: { context in
            self.backgroundView.frame = containerView.frame
            presentedView.frame = self.frameOfPresentedViewInContainerView
        })
    }
}

// MARK: ShelfTransitionManager

final class ShelfTransitionManager: NSObject, UIViewControllerTransitioningDelegate {

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        return ShelfPresentationController(
            presentedViewController: presented,
            presenting: presenting ?? source
        )
    }
    
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let shelfPresentationController = dismissed.presentationController as? ShelfPresentationController else {
            return nil
        }

        return shelfPresentationController.shelfDismissAnimationController
    }
    
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        guard let shelfDismissAnimationController = animator as? ShelfDismissAnimationController else {
            return nil
        }

        if shelfDismissAnimationController.interactiveDismissal {
            return shelfDismissAnimationController
        }

        return nil
    }
}

// MARK: ShelfDismissAnimationController

final class ShelfDismissAnimationController: UIPercentDrivenInteractiveTransition {

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

extension ShelfDismissAnimationController: UIViewControllerAnimatedTransitioning {
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
