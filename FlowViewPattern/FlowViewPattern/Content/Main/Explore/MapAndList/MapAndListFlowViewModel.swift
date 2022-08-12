//
//  MapAndListFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import Foundation

final class MapAndListFlowViewModel: ObservableObject {

    enum Page {
        case map
        case list
    }

    @Published var selectedPage: Page

    private weak var flowCoordinator: ExploreFlowCoordinator?

    init(flowCoordinator: ExploreFlowCoordinator) {
        self.flowCoordinator = flowCoordinator

        selectedPage = .map
    }
}

extension MapAndListFlowViewModel: MapAndListFlowCoordinator {

    func showMap() {
        selectedPage = .map
    }

    func showList() {
        selectedPage = .list
    }

    func continueToNews() {
        flowCoordinator?.continueToNews()
    }

    func continueToBooking() {
        flowCoordinator?.continueToBooking()
    }
}
