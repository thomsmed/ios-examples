//
//  TabBarController.swift
//  ImprovedContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/08/2022.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewControllers(
            [
                makeSinglePageControllerExample(),
                makeSegmentedPageControllerExample()
            ],
            animated: false
        )

        view.backgroundColor = .systemBackground
    }

    func makeSinglePageControllerExample() -> UIViewController {
        let singlePageViewController = SinglePageController()

        var backgroundColor: UIColor = .systemBlue
        var transition: SinglePageController.Transition = .flip

        var makeAndSetNextViewController: () -> Void = { }
        makeAndSetNextViewController = { [weak singlePageViewController] in
            backgroundColor = backgroundColor == .systemIndigo ? .systemBlue : .systemIndigo
            transition = transition == .none ? .dissolve : transition == .dissolve ? .flip : .none

            singlePageViewController?.setViewController({
                let viewController = ViewController()
                viewController.cardView.backgroundColor = backgroundColor
                viewController.label.text = "SinglePageController"
                viewController.button.addAction(.init { _ in
                    makeAndSetNextViewController()
                }, for: .primaryActionTriggered)
                return viewController
            }(), using: transition)
        }

        makeAndSetNextViewController()

        let navigationViewController = UINavigationController(
            rootViewController: singlePageViewController
        )

        navigationViewController.isNavigationBarHidden = true
        navigationViewController.tabBarItem = .init(
            title: "SinglePageController",
            image: .init(systemName: "1.circle"),
            tag: 1
        )

        return navigationViewController
    }

    func makeSegmentedPageControllerExample() -> UIViewController {
        let singlePageViewController = SinglePageController()

        var backgroundColor: UIColor = .systemBlue
        var transition: SinglePageController.Transition = .flip

        var makeAndSetNextViewController: () -> Void = { }
        makeAndSetNextViewController = { [weak singlePageViewController] in
            backgroundColor = backgroundColor == .systemIndigo ? .systemBlue : .systemIndigo
            transition = transition == .none ? .dissolve : transition == .dissolve ? .flip : .none

            singlePageViewController?.setViewController({
                let viewController = ViewController()
                viewController.cardView.backgroundColor = backgroundColor
                viewController.label.text = "SegmentedPageController"
                viewController.button.addAction(.init { _ in
                    makeAndSetNextViewController()
                }, for: .primaryActionTriggered)
                return viewController
            }(), using: transition)
        }

        makeAndSetNextViewController()

        let navigationViewController = UINavigationController(
            rootViewController: singlePageViewController
        )

        navigationViewController.isNavigationBarHidden = true
        navigationViewController.tabBarItem = .init(
            title: "SegmentedPageController",
            image: .init(systemName: "2.circle"),
            tag: 1
        )

        return navigationViewController
    }
}

