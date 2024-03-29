//
//  TabBarController.swift
//  FeatureModules
//
//  Created by Thomas Asheim Smedmann on 20/11/2022.
//

import UIKit
import CoreKit
import FeatureOneKit
import FeatureTwoKit
import FeatureThreeKit

final class TabBarController: UITabBarController {

    private var activeCoordinators: [Coordinator] = []

    private func removeChildCoordinator(_ coordinator: Coordinator) {
        activeCoordinators.removeAll(where: { $0 === coordinator })
    }

    private func makeTabOneCoordinator() -> Coordinator {
        let configuration = FeatureOneConfiguration()

        let navigationController = UINavigationController()
        navigationController.tabBarItem = .init(
            title: "One",
            image: .init(systemName: "one"),
            tag: 1
        )

        return DefaultFeatureOneCoordinator(
            configuration: configuration,
            navigationController: navigationController,
            delegate: self
        )
    }

    private func makeTabTwoCoordinator() -> Coordinator {
        let configuration = FeatureTwoConfiguration()

        let navigationController = UINavigationController()
        navigationController.tabBarItem = .init(
            title: "Two",
            image: .init(systemName: "two"),
            tag: 1
        )

        return DefaultFeatureTwoCoordinator(
            configuration: configuration,
            navigationController: navigationController,
            delegate: self
        )
    }

    private func makeModalCoordinator() -> Coordinator {
        let configuration = FeatureThreeConfiguration()

        return DefaultFeatureThreeCoordinator(
            configuration: configuration,
            delegate: self
        )
    }
}

extension TabBarController {
    func configureAndStart() {
        let tabOneCoordinator = makeTabOneCoordinator()
        let tabTwoCoordinator = makeTabTwoCoordinator()

        setViewControllers(
            [
                tabOneCoordinator.navigationController,
                tabTwoCoordinator.navigationController
            ],
            animated: false
        )

        activeCoordinators.append(tabOneCoordinator)
        activeCoordinators.append(tabTwoCoordinator)

        tabOneCoordinator.start()
        tabTwoCoordinator.start()

        selectedIndex = 0
    }
}

extension TabBarController: FeatureOneCoordinatorDelegate {
    func featureOneCoordinatorDidFinish(_ coordinator: Coordinator) {
        // Ignore (presented as tab)
    }
}

extension TabBarController: FeatureTwoCoordinatorDelegate {
    func featureTwoCoordinatorDidFinish(_ coordinator: Coordinator) {
        // Ignore (presented as tab)
    }

    func featureTwoCoordinatorDidContinue(_ coordinator: Coordinator) {
        let modalCoordinator = makeModalCoordinator()

        modalCoordinator.navigationController.isModalInPresentation = true

        activeCoordinators.append(modalCoordinator)

        modalCoordinator.start()

        present(modalCoordinator.navigationController, animated: true)
    }
}

extension TabBarController: FeatureThreeCoordinatorDelegate {
    func featureThreeCoordinatorDidFinish(_ coordinator: Coordinator) {
        coordinator.navigationController.dismiss(animated: true) { [weak self] in
            self?.removeChildCoordinator(coordinator)
        }
    }
}
