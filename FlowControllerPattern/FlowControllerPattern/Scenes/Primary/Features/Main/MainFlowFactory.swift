//
//  MainFlowFactory.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 13/07/2022.
//

import Foundation

protocol MainFlowFactory: AnyObject {
    func makeExploreFlowHost(with flowController: MainFlowController) -> ExploreFlowHost
    func makeActivityFlowHost(with flowController: MainFlowController) -> ActivityFlowHost
    func makeProfileFlowHost(with flowController: MainFlowController) -> ProfileFlowHost
    func makeBookingFlowHost(with flowController: MainFlowController) -> BookingFlowHost
}

extension DefaultAppFlowFactory: MainFlowFactory {

    func makeExploreFlowHost(with flowController: MainFlowController) -> ExploreFlowHost {
        DefaultExploreFlowHost(
            flowFactory: self,
            flowController: flowController
        )
    }

    func makeActivityFlowHost(with flowController: MainFlowController) -> ActivityFlowHost {
        DefaultActivityFlowHost(
            flowFactory: self,
            flowController: flowController
        )
    }

    func makeProfileFlowHost(with flowController: MainFlowController) -> ProfileFlowHost {
        DefaultProfileFlowHost(
            flowFactory: self,
            flowController: flowController
        )
    }

    func makeBookingFlowHost(with flowController: MainFlowController) -> BookingFlowHost {
        DefaultBookingFlowHost(
            flowFactory: self,
            flowController: flowController
        )
    }
}
