//
//  MainViewController.swift
//  ExtendedSplashScreen
//
//  Created by Thomas Asheim Smedmann on 19/04/2023.
//

import UIKit

final class MainViewController: UITabBarController {

    private lazy var homeViewController: UIViewController = {
        let viewController = UIViewController()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24)
        label.text = "There’s no place like home."

        viewController.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
        ])

        return viewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        homeViewController.tabBarItem.title = "Home"
        homeViewController.tabBarItem.image = .init(systemName: "house")

        setViewControllers([homeViewController], animated: false)
    }
}
