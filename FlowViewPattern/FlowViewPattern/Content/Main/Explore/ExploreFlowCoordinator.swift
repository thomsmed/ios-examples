//
//  ExploreFlowCoordinator.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

protocol ExploreFlowCoordinator: AnyObject {
    func continueToBooking()
}

extension DummyFlowCoordinator: ExploreFlowCoordinator {

    func continueToBooking() {
        
    }
}
