//
//  FeatureThreeCoordinator.swift
//  
//
//  Created by Thomas Asheim Smedmann on 20/11/2022.
//

import UIKit
import CoreKit

protocol FeatureThreeCoordinator: Coordinator {
    func didComplete()
}

/// Feature Three Configurations.
public struct FeatureThreeConfiguration {
    public init() {}
}

/// Feature Three Coordinator Delegate. Tracks the lifecycle of the Coordinator.
public protocol FeatureThreeCoordinatorDelegate: AnyObject {
    func featureThreeCoordinatorDidFinish(_ coordinator: Coordinator)
}

/// The Feature Three Coordinator implementation.
public final class DefaultFeatureThreeCoordinator {
    private let configuration: FeatureThreeConfiguration

    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []

    private weak var delegate: FeatureThreeCoordinatorDelegate?

    public init(
        configuration: FeatureThreeConfiguration,
        delegate: FeatureThreeCoordinatorDelegate
    ) {
        self.configuration = configuration
        self.delegate = delegate

        navigationController = CustomNavigationController()
    }
}

extension DefaultFeatureThreeCoordinator: FeatureThreeCoordinator {
    public func start() {
        let featureThreeViewController = FeatureThreeViewController(
            coordinator: self
        )
        navigationController.setViewControllers([featureThreeViewController], animated: false)
    }

    func didComplete() {
        delegate?.featureThreeCoordinatorDidFinish(self)
    }
}
