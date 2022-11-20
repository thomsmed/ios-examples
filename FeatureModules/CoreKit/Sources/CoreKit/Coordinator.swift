//
//  Coordinator.swift
//  
//
//  Created by Thomas Asheim Smedmann on 20/11/2022.
//

import Foundation

public protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

public extension Coordinator {
    func childCoordinatorDidFinish(_ coordinator: Coordinator) {
        childCoordinators.removeAll(where: { $0 === coordinator})
    }
}
