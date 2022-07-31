//
//  ExploreMapViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class ExploreMapViewModel: ObservableObject {

    private weak var flowCoordinator: ExploreFlowCoordinator?
    private let appDependencies: AppDependencies

    init(flowCoordinator: ExploreFlowCoordinator, appDependencies: AppDependencies) {
        self.flowCoordinator = flowCoordinator
        self.appDependencies = appDependencies
    }
}

extension ExploreMapViewModel {

    func bookAppointment() {
        flowCoordinator?.continueToBooking()
    }
}
