//
//  MapAndListFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import Foundation

final class MapAndListFlowViewModel: ObservableObject {

    private weak var flowCoordinator: ExploreFlowCoordinator?
    private let appDependencies: AppDependencies

    init(flowCoordinator: ExploreFlowCoordinator, appDependencies: AppDependencies) {
        self.flowCoordinator = flowCoordinator
        self.appDependencies = appDependencies
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

extension MapAndListFlowViewModel: MapAndListFlowViewFactory {

    func makeExploreMapView() -> ExploreMapView {
        ExploreMapView(
            viewModel: .init(
                flowCoordinator: self,
                appDependencies: self.appDependencies
            )
        )
    }

    func makeExploreListView() -> ExploreListView {
        ExploreListView(
            viewModel: .init(
                flowCoordinator: self,
                appDependencies: self.appDependencies
            )
        )
    }
}
