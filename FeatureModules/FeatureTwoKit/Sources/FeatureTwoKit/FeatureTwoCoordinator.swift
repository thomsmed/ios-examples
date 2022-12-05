//
//  FeatureTwoCoordinator.swift
//  
//
//  Created by Thomas Asheim Smedmann on 20/11/2022.
//

import UIKit
import CoreKit

protocol FeatureTwoCoordinator: Coordinator {
    func didComplete()
    func nextFeature()
}

/// Feature Two Configurations.
public struct FeatureTwoConfiguration {
    public init() {}
}

/// Feature Two Coordinator Delegate. Tracks the lifecycle of the Coordinator.
public protocol FeatureTwoCoordinatorDelegate: AnyObject {
    func featureTwoCoordinatorDidFinish(_ coordinator: Coordinator)
    func featureTwoCoordinatorDidContinue(_ coordinator: Coordinator)
}

/// The Feature Two Coordinator implementation.
public final class DefaultFeatureTwoCoordinator {
    private let configuration: FeatureTwoConfiguration

    public var presenter: UINavigationController
    public var childCoordinators: [Coordinator] = []

    private weak var delegate: FeatureTwoCoordinatorDelegate?

    public init(
        configuration: FeatureTwoConfiguration,
        presenter: UINavigationController,
        delegate: FeatureTwoCoordinatorDelegate
    ) {
        self.configuration = configuration
        self.presenter = presenter
        self.delegate = delegate
    }
}

extension DefaultFeatureTwoCoordinator: FeatureTwoCoordinator {
    public func start() {
        let featureTwoViewController = FeatureTwoViewController(
            coordinator: self
        )
        presenter.setViewControllers([featureTwoViewController], animated: false)
    }

    func didComplete() {
        delegate?.featureTwoCoordinatorDidFinish(self)
    }

    func nextFeature() {
        delegate?.featureTwoCoordinatorDidContinue(self)
    }
}
