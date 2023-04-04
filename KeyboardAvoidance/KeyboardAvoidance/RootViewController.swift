//
//  RootViewController.swift
//  KeyboardAvoidance
//
//  Created by Thomas Asheim Smedmann on 03/04/2023.
//

import UIKit

class RootViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let shortFormViewController = ShortFormViewController()
        shortFormViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "rectangle.inset.filled"),
            style: .plain,
            target: self,
            action: #selector(toggleKeyboardAvoidanceStrategy)
        )
        let shortFormNavigationController = UINavigationController(
            rootViewController: shortFormViewController
        )
        shortFormNavigationController.tabBarItem = .init(
            title: "Short Form",
            image: .init(systemName: "rectangle.split.2x2.fill"),
            tag: 0
        )

        let mediumFormViewController = MediumFormViewController()
        mediumFormViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "rectangle.inset.filled"),
            style: .plain,
            target: self,
            action: #selector(toggleKeyboardAvoidanceStrategy)
        )
        let mediumFormNavigationController = UINavigationController(
            rootViewController: mediumFormViewController
        )
        mediumFormNavigationController.tabBarItem = .init(
            title: "Medium Form",
            image: .init(systemName: "tablecells.fill"),
            tag: 0
        )

        let longFormViewController = LongFormViewController()
        longFormViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "rectangle.inset.filled"),
            style: .plain,
            target: self,
            action: #selector(toggleKeyboardAvoidanceStrategy)
        )
        let longFormNavigationController = UINavigationController(
            rootViewController: longFormViewController
        )
        longFormNavigationController.tabBarItem = .init(
            title: "Long Form",
            image: .init(systemName: "rectangle.split.3x3.fill"),
            tag: 0
        )

        setViewControllers([
            shortFormNavigationController,
            mediumFormNavigationController,
            longFormNavigationController
        ], animated: false)
    }

    @objc private func toggleKeyboardAvoidanceStrategy() {
        viewControllers?.forEach { viewController in
            guard
                let navigationController = viewController as? UINavigationController,
                let keyboardAvoidanceViewController = navigationController.topViewController as? KeyboardAvoidanceViewController
            else {
                return assertionFailure("This should never happen")
            }

            let adjustContentInsetInsteadOfSafeArea = !keyboardAvoidanceViewController.adjustContentInsetInsteadOfSafeArea

            keyboardAvoidanceViewController.adjustContentInsetInsteadOfSafeArea = adjustContentInsetInsteadOfSafeArea

            keyboardAvoidanceViewController.navigationItem.rightBarButtonItem?.image = adjustContentInsetInsteadOfSafeArea
                ? .init(systemName: "rectangle.center.inset.filled")
                : .init(systemName: "rectangle.inset.filled")
        }
    }
}
