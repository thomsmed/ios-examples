//
//  MainFlowCoordinator.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

protocol MainFlowCoordinator: AnyObject {
    func presentBooking()
}

extension PreviewFlowCoordinator: MainFlowCoordinator {

    func presentBooking() {
        
    }
}
