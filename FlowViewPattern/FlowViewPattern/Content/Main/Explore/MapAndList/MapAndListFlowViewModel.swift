//
//  MapAndListFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import Foundation
import Combine

final class MapAndListFlowViewModel: ObservableObject {

    @Published var selectedPage: MapAndListFlowView.Page

    private weak var flowCoordinator: ExploreFlowCoordinator?

    private var explorePageSubscription: AnyCancellable?

    init(flowCoordinator: ExploreFlowCoordinator) {
        self.flowCoordinator = flowCoordinator

        switch flowCoordinator.currentExplorePage {
        case let .store(mapPage):
            selectedPage = .map

            if case let .map(page, storeId) = mapPage {
                // Enqueue asynchronous on main to avoid loop
                DispatchQueue.main.async { [weak self] in
                    self?.continueToBooking()
                }
            }
        default:
            selectedPage = .map
        }

        explorePageSubscription = flowCoordinator.explorePage
            .compactMap { explorePage in
                if case let .store(mapPage) = explorePage {
                    return mapPage
                }
                return nil
            }
            .sink { [weak self] mapPage in
                if case let .map(page, storeId) = mapPage {
                    self?.continueToBooking()
                }
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
