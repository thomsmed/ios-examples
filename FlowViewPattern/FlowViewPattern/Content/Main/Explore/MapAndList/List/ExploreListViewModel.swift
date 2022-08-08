//
//  ExploreListViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class ExploreListViewModel: ObservableObject {

    private weak var flowCoordinator: MapAndListFlowCoordinator?
    private let appDependencies: AppDependencies

    init(flowCoordinator: MapAndListFlowCoordinator, appDependencies: AppDependencies) {
        self.flowCoordinator = flowCoordinator
        self.appDependencies = appDependencies
    }
}

extension ExploreListViewModel {

    func bookAppointment() {
        flowCoordinator?.continueToBooking()
    }
}
