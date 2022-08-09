//
//  TabBarViewController.swift
//  ExpandableTableViewCell
//
//  Created by Thomas Asheim Smedmann on 06/08/2022.
//

import UIKit

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewControllers([
            makeAccordionExampleViewController(),
            makeDetailsExampleViewController()
        ], animated: false)
    }

    private func makeAccordionExampleViewController() -> UIViewController {
        let navigationController = UINavigationController(
            rootViewController: AccordionTableViewController(style: .plain)
        )
        navigationController.tabBarItem = .init(
            title: "Accordion",
            image: .init(systemName: "chevron.up.chevron.down"),
            tag: 1
        )
        return navigationController
    }

    private func makeDetailsExampleViewController() -> UIViewController {
        let navigationController = UINavigationController(
            rootViewController: DetailsTableViewController(style: .plain)
        )
        navigationController.tabBarItem = .init(
            title: "Expandable details",
            image: .init(systemName: "info.circle"),
            tag: 1
        )
        return navigationController
    }
}
