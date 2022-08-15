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
        case let .store(mapAndListPage):
            switch mapAndListPage {
            case let .map(storePage, storeId):
                selectedPage = .map

                guard let storeId = storeId else {
                    return
                }

                // Enqueue asynchronous on main to avoid loop
                DispatchQueue.main.async { [weak self] in
                    print("storeId", storeId)
                    print("storePage", storePage)

                    self?.continueToBooking()
                }
            case .list:
                selectedPage = .list
            }
        default:
            selectedPage = .map
        }

        explorePageSubscription = flowCoordinator.explorePage
            .compactMap { explorePage in
                if case let .store(mapAndListPage) = explorePage {
                    return mapAndListPage
                }
                return nil
            }
            .sink { [weak self] mapAndListPage in
                switch mapAndListPage {
                case let .map(storePage, storeId):
                    self?.selectedPage = .map

                    guard let storeId = storeId else {
                        return
                    }

                    print("storeId", storeId)
                    print("storePage", storePage)

                    self?.continueToBooking()
                case .list:
                    self?.selectedPage = .list
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
