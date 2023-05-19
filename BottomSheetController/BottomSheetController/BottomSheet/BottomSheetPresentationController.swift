//
//  BottomSheetPresentationController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 28/04/2023.
//

import UIKit

final class BottomSheetPresentationController: UIPresentationController {

    private lazy var backdropView: UIView = {
        let view = UIView()
        view.backgroundColor = sheetBackdropColor
        view.alpha = 0
        return view
    }()

    // How much the sheet can stretch beyond its original height/offset.
    private static let sheetStretchOffset: CGFloat = 16

    let bottomSheetInteractiveDismissalTransition = BottomSheetInteractiveDismissalTransition(
        stretchOffset: sheetStretchOffset
    )

    let sheetTopInset: CGFloat
    let sheetCornerRadius: CGFloat
    let sheetSizingFactor: CGFloat
    let sheetBackdropColor: UIColor

    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        return gestureRecognizer
    }()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan))
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

        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
    }

    @objc private func onTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Make sure there is no ongoing pan gesture.
        guard panGestureRecognizer.state == .possible else {
            return
        }

        // Cancel any in flight animation before dismissing the sheet.
        bottomSheetInteractiveDismissalTransition.cancel()

        presentingViewController.dismiss(animated: true)
    }

    @objc private func onPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let presentedView = presentedView else {
            return
        }

        let translation = gestureRecognizer.translation(in: presentedView)

        switch gestureRecognizer.state {
            case .began:
                let startingTowardsDismissal = bottomSheetInteractiveDismissalTransition.checkIfPotentialDismissalAndStart(
                    moving: presentedView, using: translation, asInteractiveDismissal: panToDismissEnabled
                )

                if startingTowardsDismissal, !presentedViewController.isBeingDismissed {
                    presentingViewController.dismiss(animated: true)
                }
            case .changed:
                let movingTowardsDismissal = bottomSheetInteractiveDismissalTransition.checkIfPotentialDismissalAndMove(
                    presentedView, using: translation
                )

                if movingTowardsDismissal, !presentedViewController.isBeingDismissed {
                    presentingViewController.dismiss(animated: true)
                }
            default:
                let velocity = gestureRecognizer.velocity(in: presentedView)
                bottomSheetInteractiveDismissalTransition.stop(
                    moving: presentedView, with: velocity
                )
        }
    }

    // MARK: UIPresentationController

    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView else {
            return
        }

        presentedView.addGestureRecognizer(panGestureRecognizer)

        presentedView.clipsToBounds = true
        presentedView.layer.cornerRadius = sheetCornerRadius
        presentedView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]

        guard let containerView = containerView else {
            return
        }

        backdropView.addGestureRecognizer(tapGestureRecognizer)

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

        // Define a layout guide we can constrain the presented view to.
        // This layout guide will act as the outer boundaries for the presented view.
        let bottomSheetLayoutGuide = UILayoutGuide()
        containerView.addLayoutGuide(bottomSheetLayoutGuide)

        containerView.addSubview(presentedView)

        presentedView.translatesAutoresizingMaskIntoConstraints = false

        let maximumHeightConstraint = presentedView.heightAnchor.constraint(
            lessThanOrEqualTo: bottomSheetLayoutGuide.heightAnchor,
            // We don't want the sheet to stretch beyond the top of our defined boundaries (`bottomSheetLayoutGuide`).
            constant: -(sheetTopInset + Self.sheetStretchOffset)
        )

        // Prevents conflicts with the height constraint used by the animated transition.
        maximumHeightConstraint.priority = .required - 1

        let preferredHeightConstraint = presentedView.heightAnchor.constraint(
            equalTo: bottomSheetLayoutGuide.heightAnchor,
            multiplier: sheetSizingFactor
        )

        preferredHeightConstraint.priority = .fittingSizeLevel

        let heightConstraint = presentedView.heightAnchor.constraint(
            equalToConstant: 0
        )

        let bottomConstraint = presentedView.bottomAnchor.constraint(
            equalTo: bottomSheetLayoutGuide.bottomAnchor
        )

        NSLayoutConstraint.activate([
            bottomSheetLayoutGuide.topAnchor.constraint(
                equalTo: containerView.safeAreaLayoutGuide.topAnchor
            ),
            bottomSheetLayoutGuide.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            ),
            bottomSheetLayoutGuide.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            bottomSheetLayoutGuide.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),

            presentedView.leadingAnchor.constraint(
                equalTo: bottomSheetLayoutGuide.leadingAnchor
            ),
            presentedView.trailingAnchor.constraint(
                equalTo: bottomSheetLayoutGuide.trailingAnchor
            ),
            bottomConstraint,
            maximumHeightConstraint,
            preferredHeightConstraint,
        ])

        bottomSheetInteractiveDismissalTransition.heightConstraint = heightConstraint
        bottomSheetInteractiveDismissalTransition.bottomConstraint = bottomConstraint

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
            presentedView?.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    override func dismissalTransitionWillBegin() {
        guard
            let transitionCoordinator = presentingViewController.transitionCoordinator,
            transitionCoordinator.isAnimated
        else {
            return
        }

        transitionCoordinator.animate { context in
            self.backdropView.alpha = 0
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backdropView.removeFromSuperview()
            presentedView?.removeFromSuperview()
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
