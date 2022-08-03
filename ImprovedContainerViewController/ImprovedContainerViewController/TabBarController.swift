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
        let singlePageController = SinglePageController()

        var page: Int = 2
        var transition: SinglePageController.Transition = .flip

        var makeAndSetNextViewController: () -> Void = { }
        makeAndSetNextViewController = { [weak singlePageController] in
            page = page > 1 ? 1 : 2
            transition = transition == .none ? .dissolve : transition == .dissolve ? .flip : .none

            singlePageController?.setViewController({
                let viewController = ViewController()
                viewController.label.text = "Page \(page == 1 ? "one" : "two")"
                viewController.cardView.backgroundColor = page == 1 ? .systemBlue : .systemIndigo
                viewController.button.addAction(.init { _ in
                    makeAndSetNextViewController()
                }, for: .primaryActionTriggered)
                return viewController
            }(), using: transition)
        }

        makeAndSetNextViewController()

        let navigationViewController = UINavigationController(
            rootViewController: singlePageController
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
