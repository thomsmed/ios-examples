//
//  DialogTransitionManager.swift
//  CustomPresentationController
//
//  Created by Thomas Asheim Smedmann on 05/11/2021.
//

import UIKit

// MARK: DialogPresentationController

final class DialogPresentationController: UIPresentationController {
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
    
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
    
extension DialogPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let frame = containerView.frame
        var width = min(frame.width, frame.height)
        width = width * 4 / 6
        let paddingLeft = (frame.width - width) / 2
        let paddingTop = (frame.height - width) / 2
        return CGRect(x: frame.minX + paddingLeft, y: frame.minY + paddingTop, width: width, height: width)
    }
    
    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView else { return }
        
        presentedView.layer.cornerRadius = 10
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

// MARK: DialogTransitionManager

final class DialogTransitionManager: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DialogPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DialogAnimationController(animationType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DialogAnimationController(animationType: .dismiss)
    }
}

// MARK: UIViewControllerAnimatedTransitioning

final class DialogAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    enum AnimationType {
        case present
        case dismiss
    }
    
    private let animationType: AnimationType
    private let animationDuration: TimeInterval
    
    init(animationType: AnimationType, animationDuration: TimeInterval = 0.3) {
        self.animationType = animationType
        self.animationDuration = animationDuration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch animationType {
        case .present:
            guard
                let toViewController = transitionContext.viewController(forKey: .to),
                let toView = transitionContext.view(forKey: .to)
            else {
                return transitionContext.completeTransition(false)
            }
            transitionContext.containerView.addSubview(toView)
            presentAnimation(with: transitionContext, and: toViewController, animating: toView)
        case .dismiss:
            guard
                let fromView = transitionContext.view(forKey: .from)
            else {
                return transitionContext.completeTransition(false)
            }
            transitionContext.containerView.addSubview(fromView)
            dismissAnimation(with: transitionContext, animating: fromView)
        }
    }
    
    private func presentAnimation(with transitionContext: UIViewControllerContextTransitioning,
                                  and viewController: UIViewController,
                                  animating view: UIView) {
        let finalFrame = transitionContext.finalFrame(for: viewController)
        view.frame = finalFrame
        view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        view.alpha = 0
        let propertyAnimator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: .easeOut, animations: {
            view.transform = .identity
            view.alpha = 1
        })
        propertyAnimator.addCompletion({ _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        propertyAnimator.startAnimation()
    }
    
    private func dismissAnimation(with transitionContext: UIViewControllerContextTransitioning,
                                  animating view: UIView) {
        let propertyAnimator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: .easeOut, animations: {
            view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            view.alpha = 0
        })
        propertyAnimator.addCompletion({ _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        propertyAnimator.startAnimation()
    }
}
