//
//  Coordinator.swift
//  
//
//  Created by Thomas Asheim Smedmann on 20/11/2022.
//

import UIKit

public protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }

    func start()
}

public extension Coordinator {
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.removeAll(where: { $0 === coordinator })
    }
}
