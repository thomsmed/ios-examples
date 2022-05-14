//
//  DialogTransitioningDelegate.swift
//  DialogController
//
//  Created by Thomas Asheim Smedmann on 09/05/2022.
//

import UIKit

// MARK: DialogTransitioningDelegate

final class DialogTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private weak var currentDialogPresentationController: DialogPresentationController?

    var preferredDialogEdgeInset: CGFloat
    var preferredDialogCornerRadius: CGFloat
    var preferredDialogSizingFactor: DialogPresentationController.DialogSizing
    var preferredDialogBackdropColor: UIColor

    var tapToDismissEnabled: Bool = true {
        didSet {
            currentDialogPresentationController?.tapGestureRecognizer.isEnabled = tapToDismissEnabled
        }
    }

    init(
        preferredDialogEdgeInset: CGFloat,
        preferredDialogCornerRadius: CGFloat,
        preferredDialogSizingFactor: DialogPresentationController.DialogSizing,
        preferredDialogBackdropColor: UIColor
    ) {
        self.preferredDialogEdgeInset = preferredDialogEdgeInset
        self.preferredDialogCornerRadius = preferredDialogCornerRadius
        self.preferredDialogSizingFactor = preferredDialogSizingFactor
        self.preferredDialogBackdropColor = preferredDialogBackdropColor
        super.init()
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let dialogPresentationController = DialogPresentationController(
            presentedViewController: presented,
            presenting: presenting ?? source,
            dialogEdgeInset: preferredDialogEdgeInset,
            dialogCornerRadius: preferredDialogCornerRadius,
            dialogSizingFactor: preferredDialogSizingFactor,
            dialogBackdropColor: preferredDialogBackdropColor
        )

        dialogPresentationController.tapGestureRecognizer.isEnabled = tapToDismissEnabled

        currentDialogPresentationController = dialogPresentationController

        return dialogPresentationController
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        DialogAnimatedTransitioning(animationType: .present)
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        DialogAnimatedTransitioning(animationType: .dismiss)
    }
}

// MARK: DialogPresentationController

final class DialogPresentationController: UIPresentationController {

    struct DialogSizing {
        let multiplier: CGFloat
        let verticalAdjustmentMultiplier: CGFloat
    }

    private lazy var backdropView: UIView = {
        let view = UIView()
        view.backgroundColor = dialogBackdropColor
        view.alpha = 0
        return view
    }()

    let dialogEdgeInset: CGFloat
    let dialogCornerRadius: CGFloat
    let dialogSizingFactor: DialogSizing
    let dialogBackdropColor: UIColor

    lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        dialogEdgeInset: CGFloat,
        dialogCornerRadius: CGFloat,
        dialogSizingFactor: DialogSizing,
        dialogBackdropColor: UIColor
    ) {
        self.dialogEdgeInset = dialogEdgeInset
        self.dialogCornerRadius = dialogCornerRadius
        self.dialogSizingFactor = dialogSizingFactor
        self.dialogBackdropColor = dialogBackdropColor
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

    // MARK: UIPresentationController

    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView else {
            return
        }

        presentedView.layer.cornerRadius = dialogCornerRadius

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

        NSLayoutConstraint.activate([
            presentedView.centerXAnchor.constraint(
                equalTo: containerView.safeAreaLayoutGuide.centerXAnchor
            ),
            presentedView.centerYAnchor.constraint(
                equalTo: containerView.safeAreaLayoutGuide.centerYAnchor
            ),
            presentedView.topAnchor.constraint(
                greaterThanOrEqualTo: containerView.safeAreaLayoutGuide.topAnchor,
                constant: dialogEdgeInset
            ),
            presentedView.leadingAnchor.constraint(
                greaterThanOrEqualTo: containerView.safeAreaLayoutGuide.leadingAnchor,
                constant: dialogEdgeInset
            ),
            presentedView.trailingAnchor.constraint(
                lessThanOrEqualTo: containerView.safeAreaLayoutGuide.trailingAnchor,
                constant: dialogEdgeInset
            ),
            presentedView.bottomAnchor.constraint(
                lessThanOrEqualTo: containerView.safeAreaLayoutGuide.bottomAnchor,
                constant: dialogEdgeInset
            )
        ])

        let preferredPortraitWidthConstraint = presentedView.widthAnchor.constraint(
            equalTo: containerView.safeAreaLayoutGuide.widthAnchor,
            multiplier: dialogSizingFactor.multiplier
        )
        preferredPortraitWidthConstraint.priority = dialogSizingFactor.multiplier == 0 ? .fittingSizeLevel : .required - 1

        let preferredPortraitHeightConstraint = presentedView.heightAnchor.constraint(
            equalTo: containerView.safeAreaLayoutGuide.widthAnchor,
            multiplier: dialogSizingFactor.multiplier * dialogSizingFactor.verticalAdjustmentMultiplier
        )
        preferredPortraitHeightConstraint.priority = dialogSizingFactor.verticalAdjustmentMultiplier < 10 ? .fittingSizeLevel : .required - 1

        portraitConstraints = [
            preferredPortraitWidthConstraint,
            preferredPortraitHeightConstraint
        ]

        let preferredLandscapeWidthConstraint = presentedView.widthAnchor.constraint(
            equalTo: containerView.safeAreaLayoutGuide.heightAnchor,
            multiplier: dialogSizingFactor.multiplier
        )
        preferredLandscapeWidthConstraint.priority = dialogSizingFactor.multiplier == 0 ? .fittingSizeLevel : .required - 1

        let preferredLandscapeHeightConstraint = presentedView.heightAnchor.constraint(
            equalTo: containerView.safeAreaLayoutGuide.heightAnchor,
            multiplier: dialogSizingFactor.multiplier * dialogSizingFactor.verticalAdjustmentMultiplier
        )
        preferredLandscapeHeightConstraint.priority = dialogSizingFactor.verticalAdjustmentMultiplier < 10 ? .fittingSizeLevel : .required - 1

        landscapeConstraints = [
            preferredLandscapeWidthConstraint,
            preferredLandscapeHeightConstraint
        ]

        if traitCollection.verticalSizeClass != .compact  {
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            NSLayoutConstraint.activate(landscapeConstraints)
        }

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
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.verticalSizeClass != .compact {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }
}

// MARK: BottomSheetInteractiveTransition

final class DialogAnimatedTransitioning: NSObject {

    enum AnimationType {
        case present
        case dismiss
    }

    private let transitionDuration: CGFloat = 0.33
    private let animationCurve: UIView.AnimationCurve = .easeInOut

    private let animationType: AnimationType

    init(animationType: AnimationType) {
        self.animationType = animationType
    }

    private func presentAnimation(
        with transitionContext: UIViewControllerContextTransitioning,
        and viewController: UIViewController,
        animating view: UIView
    ) {
        let finalFrame = transitionContext.finalFrame(for: viewController)
        view.frame = finalFrame
        view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        view.alpha = 0

        UIView.animate(
            withDuration: transitionDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 3,
            options: .curveEaseInOut,
            animations: {
                view.transform = .identity
                view.alpha = 1
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }

    private func dismissAnimation(
        with transitionContext: UIViewControllerContextTransitioning,
        animating view: UIView
    ) {
        UIView.animate(
            withDuration: transitionDuration,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                view.alpha = 0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

extension DialogAnimatedTransitioning: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch animationType {
        case .present:
            guard
                let toViewController = transitionContext.viewController(forKey: .to),
                let toView = transitionContext.view(forKey: .to)
            else {
                return transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            transitionContext.containerView.addSubview(toView)
            presentAnimation(with: transitionContext, and: toViewController, animating: toView)
        case .dismiss:
            guard
                let fromView = transitionContext.view(forKey: .from)
            else {
                return transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            transitionContext.containerView.addSubview(fromView)
            dismissAnimation(with: transitionContext, animating: fromView)
        }
    }
}
