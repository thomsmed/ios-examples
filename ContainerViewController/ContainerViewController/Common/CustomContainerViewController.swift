//
//  CustomContainerViewController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit
import Cartography

class CustomContainerViewController: UIViewController {

    private func removeChildren() {
        children.forEach { child in
            child.willMove(toParent: nil)

            child.view.removeFromSuperview()

            child.removeFromParent()
        }
    }

    private func setViewController(_ viewController: UIViewController) {
        removeChildren()

        addChild(viewController)

        view.addSubview(viewController.view)

        constrain(viewController.view, view) { child, container in
            child.edges == container.edges
        }

        viewController.didMove(toParent: self)
    }

    private func flipTransition(to toViewController: UIViewController) {
        guard let fromViewController = children.first else {
            return setViewController(toViewController)
        }

        addChild(toViewController)

        fromViewController.willMove(toParent: nil)

        view.addSubview(toViewController.view)

        constrain(toViewController.view, view) { view, container in
            view.edges == container.edges
        }

        view.layoutIfNeeded()

        UIView.transition(
            from: fromViewController.view,
            to: toViewController.view,
            duration: 1,
            options: [.transitionFlipFromRight]
        )

        fromViewController.removeFromParent()

        toViewController.didMove(toParent: self)
    }

    private func dissolveTransition(to toViewController: UIViewController) {
        guard let fromViewController = children.first else {
            return setViewController(toViewController)
        }

        addChild(toViewController)

        fromViewController.willMove(toParent: nil)

        view.addSubview(toViewController.view)

        constrain(toViewController.view, view) { view, container in
            view.edges == container.edges
        }

        view.layoutIfNeeded()

        UIView.transition(
            from: fromViewController.view,
            to: toViewController.view,
            duration: 1,
            options: [.transitionCrossDissolve]
        )

        fromViewController.removeFromParent()

        toViewController.didMove(toParent: self)
    }
}

extension CustomContainerViewController {

    enum TransitionAnimation {
        case none
        case flip
        case dissolve
    }

    func setViewController(_ viewController: UIViewController, with animation: TransitionAnimation) {
        switch animation {
        case .none:
            setViewController(viewController)
        case .flip:
            flipTransition(to: viewController)
        case .dissolve:
            dissolveTransition(to: viewController)
        }
    }
}
