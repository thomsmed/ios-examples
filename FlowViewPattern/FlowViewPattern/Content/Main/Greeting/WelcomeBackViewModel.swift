//
//  WelcomeBackViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 08/08/2022.
//

import Foundation

final class WelcomeBackViewModel: ObservableObject {

    private weak var flowCoordinator: MainFlowCoordinator?

    init(flowCoordinator: MainFlowCoordinator) {
        self.flowCoordinator = flowCoordinator
    }
}

extension WelcomeBackViewModel {

    func continueToBooking() {
        flowCoordinator?.presentBooking()
    }
}
