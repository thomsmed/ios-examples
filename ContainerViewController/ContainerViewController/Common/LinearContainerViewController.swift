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

        // Alternative 1 - Using Auto Layout Constraints:
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
        ) { completed in
            previousViewController.removeFromParent()
            viewController.didMove(toParent: self)
        }

        // Alternative 2 - Manually setting frames:
//        viewController.view.frame = view.frame
//
//        transition(
//            from: previousViewController,
//            to: viewController,
//            duration: 1,
//            options: [.transitionFlipFromRight],
//            animations: nil
//        ) { completed in
//            previousViewController.removeFromParent()
//            viewController.didMove(toParent: self)
//        }
    }

    private func dissolveTransition(to viewController: UIViewController) {
        guard let previousViewController = children.first else {
            return setChildViewController(viewController)
        }

        addChild(viewController)

        previousViewController.willMove(toParent: nil)

        // Alternative 1 - Using Auto Layout Constraints:
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
        ) { completed in
            previousViewController.removeFromParent()
            viewController.didMove(toParent: self)
        }

        // Alternative 2 - Manually setting frames:
//        viewController.view.frame = view.frame
//
//        transition(
//            from: previousViewController,
//            to: viewController,
//            duration: 1,
//            options: [.transitionCrossDissolve],
//            animations: nil
//        ) { completed in
//            previousViewController.removeFromParent()
//            viewController.didMove(toParent: self)
//        }
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
