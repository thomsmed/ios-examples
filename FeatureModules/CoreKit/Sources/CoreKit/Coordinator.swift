//
//  Coordinator.swift
//  
//
//  Created by Thomas Asheim Smedmann on 20/11/2022.
//

import UIKit

public protocol Coordinator: AnyObject {
    var presenter: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }

    func start()
}

public extension Coordinator {
    func childCoordinatorDidFinish(_ coordinator: Coordinator) {
        childCoordinators.removeAll(where: { $0 === coordinator })
    }
}
