//
//  ExploreListViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

struct ExploreListViewModel {

    private weak var flowCoordinator: MapAndListFlowCoordinator?

    init(flowCoordinator: MapAndListFlowCoordinator) {
        self.flowCoordinator = flowCoordinator
    }
}

extension ExploreListViewModel {

    func bookAppointment() {
        flowCoordinator?.continueToBooking()
    }
}
