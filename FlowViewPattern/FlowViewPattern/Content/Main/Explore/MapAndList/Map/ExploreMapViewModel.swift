//
//  ExploreMapViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

struct ExploreMapViewModel {

    private weak var flowCoordinator: MapAndListFlowCoordinator?

    init(flowCoordinator: MapAndListFlowCoordinator) {
        self.flowCoordinator = flowCoordinator
    }
}

extension ExploreMapViewModel {

    func bookAppointment() {
        flowCoordinator?.continueToBooking()
    }
}
