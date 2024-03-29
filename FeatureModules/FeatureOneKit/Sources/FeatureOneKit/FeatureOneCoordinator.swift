//
//  FeatureOneCoordinator.swift
//  
//
//  Created by Thomas Asheim Smedmann on 20/11/2022.
//

import UIKit
import CoreKit

protocol FeatureOneCoordinator: Coordinator {
    func didComplete()
}

/// Feature One Configurations.
public struct FeatureOneConfiguration {
    public init() {}
}

/// Feature One Coordinator Delegate. Tracks the lifecycle of the Coordinator.
public protocol FeatureOneCoordinatorDelegate: AnyObject {
    func featureOneCoordinatorDidFinish(_ coordinator: Coordinator)
}

/// The Feature One Coordinator implementation.
public final class DefaultFeatureOneCoordinator {
    private let configuration: FeatureOneConfiguration

    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []

    private weak var delegate: FeatureOneCoordinatorDelegate?

    public init(
        configuration: FeatureOneConfiguration,
        navigationController: UINavigationController,
        delegate: FeatureOneCoordinatorDelegate
    ) {
        self.configuration = configuration
        self.navigationController = navigationController
        self.delegate = delegate
    }
}

extension DefaultFeatureOneCoordinator: FeatureOneCoordinator {
    public func start() {
        let featureOneViewController = FeatureOneViewController(
            coordinator: self
        )
        navigationController.setViewControllers([featureOneViewController], animated: false)
    }

    func didComplete() {
        delegate?.featureOneCoordinatorDidFinish(self)
    }
}
