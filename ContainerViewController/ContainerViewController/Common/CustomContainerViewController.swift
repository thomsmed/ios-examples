//
//  CustomContainerViewController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit
import Cartography

class CustomContainerViewController: UIViewController {

    private func removeChildViewControllers() {
        children.forEach { child in
            child.willMove(toParent: nil)

            child.view.removeFromSuperview()

            child.removeFromParent()
        }
    }

    private func setViewController(_ viewController: UIViewController) {
        removeChildViewControllers()

        addChild(viewController)

        view.addSubview(viewController.view)

        constrain(viewController.view, view) { child, container in
            child.edges == container.edges
        }

        viewController.didMove(toParent: self)
    }

    private func flipTransition(to viewController: UIViewController) {
        guard let previousViewController = children.first else {
            return setViewController(viewController)
        }

        addChild(viewController)

        previousViewController.willMove(toParent: nil)

        view.addSubview(viewController.view)

        constrain(viewController.view, view) { view, container in
            view.edges == container.edges
        }

        view.layoutIfNeeded()

        UIView.transition(
            from: previousViewController.view,
            to: viewController.view,
            duration: 1,
            options: [.transitionFlipFromRight]
        )

        previousViewController.removeFromParent()

        viewController.didMove(toParent: self)
    }

    private func dissolveTransition(to viewController: UIViewController) {
        guard let previousViewController = children.first else {
            return setViewController(viewController)
        }

        addChild(viewController)

        previousViewController.willMove(toParent: nil)

        view.addSubview(viewController.view)

        constrain(viewController.view, view) { view, container in
            view.edges == container.edges
        }

        view.layoutIfNeeded()

        UIView.transition(
            from: previousViewController.view,
            to: viewController.view,
            duration: 1,
            options: [.transitionCrossDissolve]
        )

        previousViewController.removeFromParent()

        viewController.didMove(toParent: self)
    }
}

extension CustomContainerViewController {

    enum Transition {
        case none
        case flip
        case dissolve
    }

    func setViewController(_ viewController: UIViewController, using transition: Transition) {
        switch transition {
        case .none:
            setViewController(viewController)
        case .flip:
            flipTransition(to: viewController)
        case .dissolve:
            dissolveTransition(to: viewController)
        }
    }
}
