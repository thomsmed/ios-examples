//
//  MapAndListFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import Foundation
import Combine

final class MapAndListFlowViewModel: ObservableObject {

    @Published var selectedPage: MapAndListFlowView.Page = .map

    private weak var flowCoordinator: ExploreFlowCoordinator?

    init(flowCoordinator: ExploreFlowCoordinator) {
        self.flowCoordinator = flowCoordinator
    }

    func go(to path: AppPath.Main.Explore.Store) {
        switch path {
        case let .map(storePath, storeId):
            selectedPage = .map

            guard let storeId = storeId else {
                return
            }

            print("storeId", storeId)
            print("storePath", storePath)

            continueToBooking()
        case .list:
            selectedPage = .list
        }
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
