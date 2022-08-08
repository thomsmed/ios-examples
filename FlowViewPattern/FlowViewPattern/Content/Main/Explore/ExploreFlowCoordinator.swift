//
//  ExploreFlowCoordinator.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

protocol ExploreFlowCoordinator: AnyObject {
    func continueToNews()
    func continueToBooking()
}

extension MockFlowCoordinator: ExploreFlowCoordinator {

    func continueToNews() {
        
    }

    func continueToBooking() {
        
    }
}
