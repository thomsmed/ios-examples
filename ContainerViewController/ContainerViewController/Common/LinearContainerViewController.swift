//
//  LinearContainerViewController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit
import Cartography

class LinearContainerViewController: UIViewController {

    private func removeChildViewControllers() {
        children.forEach { viewController in
            viewController.willMove(toParent: nil)

            viewController.view.removeFromSuperview()

            viewController.removeFromParent()
        }
    }

    private func setChildViewController(_ viewController: UIViewController) {
        removeChildViewControllers()

        addChild(viewController)

        view.addSubview(viewController.view)

        constrain(viewController.view, view) { view, container in
            view.edges == container.edges
        }

        viewController.didMove(toParent: self)
    }

    private func flipTransition(to viewController: UIViewController) {
        guard let previousViewController = children.first else {
            return setChildViewController(viewController)
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
            return setChildViewController(viewController)
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

extension LinearContainerViewController {

    enum Transition {
        case none
        case flip
        case dissolve
    }

    func setViewController(_ viewController: UIViewController, using transition: Transition) {
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
