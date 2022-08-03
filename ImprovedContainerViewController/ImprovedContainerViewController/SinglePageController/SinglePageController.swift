//
//  SinglePageController.swift
//  ImprovedContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/08/2022.
//

import UIKit

class SinglePageController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return viewController?.preferredStatusBarStyle ?? .default
    }

    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        false // Override this when animating views using constraints
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewController?.beginAppearanceTransition(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewController?.endAppearanceTransition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewController?.beginAppearanceTransition(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewController?.endAppearanceTransition()
    }

    private var isCurrentlyVisible: Bool {
        viewIfLoaded?.window != nil
    }

    private func addAndConstrain(viewControllerView: UIView) {
        view.addSubview(viewControllerView)

        viewControllerView.translatesAutoresizingMaskIntoConstraints = false

        let trailingConstraint = viewControllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        trailingConstraint.priority = .required - 1 // To avoid conflicts during initial layout calculations

        let bottomConstraint = viewControllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.priority = .required - 1 // To avoid conflicts during initial layout calculations

        NSLayoutConstraint.activate([
            viewControllerView.topAnchor.constraint(equalTo: view.topAnchor),
            viewControllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingConstraint,
            bottomConstraint
        ])

        viewControllerView.layoutIfNeeded()
    }

    private func removeChildViewControllers() {
        children.forEach { viewController in
            viewController.willMove(toParent: nil)

            if isCurrentlyVisible {
                viewController.beginAppearanceTransition(false, animated: false)
                viewController.endAppearanceTransition()
            }

            viewController.view.removeFromSuperview()

            viewController.removeFromParent()
        }
    }

    private func setChildViewController(_ viewController: UIViewController) {
        removeChildViewControllers()

        addChild(viewController)

        addAndConstrain(viewControllerView: viewController.view)

        if isCurrentlyVisible {
            viewController.beginAppearanceTransition(true, animated: false)
            viewController.endAppearanceTransition()
        }

        viewController.didMove(toParent: self)
    }

    private func flipTransition(to viewController: UIViewController) {
        guard let previousViewController = children.first else {
            return setChildViewController(viewController)
        }

        addChild(viewController)

        previousViewController.willMove(toParent: nil)

        addAndConstrain(viewControllerView: viewController.view)

        previousViewController.beginAppearanceTransition(false, animated: true)
        viewController.beginAppearanceTransition(true, animated: true)

        UIView.transition(
            from: previousViewController.view,
            to: viewController.view,
            duration: 0.5,
            options: [
                .transitionFlipFromRight,
                .beginFromCurrentState,
                .allowAnimatedContent
            ]
        ) { completed in
            previousViewController.endAppearanceTransition()
            previousViewController.removeFromParent()
            viewController.endAppearanceTransition()
            viewController.didMove(toParent: self)
        }
    }

    private func dissolveTransition(to viewController: UIViewController) {
        guard let previousViewController = children.first else {
            return setChildViewController(viewController)
        }

        addChild(viewController)

        previousViewController.willMove(toParent: nil)

        addAndConstrain(viewControllerView: viewController.view)

        previousViewController.beginAppearanceTransition(false, animated: true)
        viewController.beginAppearanceTransition(true, animated: true)

        UIView.transition(
            from: previousViewController.view,
            to: viewController.view,
            duration: 0.25,
            options: [
                .transitionCrossDissolve,
                .beginFromCurrentState,
                .allowAnimatedContent
            ]
        ) { completed in
            previousViewController.endAppearanceTransition()
            previousViewController.removeFromParent()
            viewController.endAppearanceTransition()
            viewController.didMove(toParent: self)
        }
    }
}

extension SinglePageController {

    enum Transition {
        case none
        case flip
        case dissolve
    }

    var viewController: UIViewController? {
        get {
            children.first
        }
        set {
            guard let newViewController = newValue else {
                return removeChildViewControllers()
            }
            setChildViewController(newViewController)
        }
    }

    func setViewController(_ viewController: UIViewController, using transition: Transition) {
        guard isCurrentlyVisible else {
            return setChildViewController(viewController)
        }

        switch transition {
        case .none:
            setChildViewController(viewController)
        case .flip:
            flipTransition(to: viewController)
        case .dissolve:
            dissolveTransition(to: viewController)
        }
    }
}
