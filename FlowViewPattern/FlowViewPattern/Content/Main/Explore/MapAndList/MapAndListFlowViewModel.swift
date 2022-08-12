//
//  MapAndListFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import Foundation

final class MapAndListFlowViewModel: ObservableObject {

    private weak var flowCoordinator: ExploreFlowCoordinator?

    init(flowCoordinator: ExploreFlowCoordinator) {
        self.flowCoordinator = flowCoordinator
    }
}

extension MapAndListFlowViewModel: MapAndListFlowCoordinator {

    func showMap() {

    }

    func showList() {

    }

    func continueToNews() {
        flowCoordinator?.continueToNews()
    }

    func continueToBooking() {
        flowCoordinator?.continueToBooking()
    }
}
