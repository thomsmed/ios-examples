//
//  RootViewController.swift
//  InteractiveAnimations
//
//  Created by Thomas Asheim Smedmann on 02/05/2023.
//

import UIKit

final class RootViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let bouncyCubeViewController = BouncyCubeViewController()
        bouncyCubeViewController.tabBarItem = UITabBarItem(
            title: "Bouncy Cube",
            image: UIImage(systemName: "house"),
            tag: 0
        )

        let bottomSheetAnimationViewController = BottomSheetAnimationViewController()
        bottomSheetAnimationViewController.tabBarItem = UITabBarItem(
            title: "Bottom Sheet",
            image: UIImage(systemName: "house"),
            tag: 1
        )

        setViewControllers(
            [
                bouncyCubeViewController,
                bottomSheetAnimationViewController
            ],
            animated: false
        )
    }
}
