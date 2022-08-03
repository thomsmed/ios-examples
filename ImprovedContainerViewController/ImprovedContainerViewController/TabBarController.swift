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
                viewController.cardView.backgroundColor = page == 1 ? .systemRed : .systemBlue
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
        let segmentedPageController = SegmentedPageController()

        let segmentOneViewController = ViewController()
        segmentOneViewController.title = "Segment one"
        segmentOneViewController.cardView.backgroundColor = .systemRed
        segmentOneViewController.label.text = "Segment one"
        segmentOneViewController.button.addAction(.init { [weak segmentedPageController] _ in
            segmentedPageController?.setSelectedSegmentIndex(1, using: .slide)
        }, for: .primaryActionTriggered)

        let segmentTwoViewController = ViewController()
        segmentTwoViewController.title = "Segment two"
        segmentTwoViewController.cardView.backgroundColor = .systemGreen
        segmentTwoViewController.label.text = "Segment two"
        segmentTwoViewController.button.addAction(.init { [weak segmentedPageController] _ in
            segmentedPageController?.setSelectedSegmentIndex(2, using: .slide)
        }, for: .primaryActionTriggered)

        let segmentThreeViewController = ViewController()
        segmentThreeViewController.title = "Segment three"
        segmentThreeViewController.cardView.backgroundColor = .systemBlue
        segmentThreeViewController.label.text = "Segment three"
        segmentThreeViewController.button.addAction(.init { [weak segmentedPageController] _ in
            segmentedPageController?.setSelectedSegmentIndex(0, using: .slide)
        }, for: .primaryActionTriggered)

        segmentedPageController.viewControllers = [
            segmentOneViewController,
            segmentTwoViewController,
            segmentThreeViewController
        ]

        let navigationViewController = UINavigationController(
            rootViewController: segmentedPageController
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
