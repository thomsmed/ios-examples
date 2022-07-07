//
//  StoreViewModel.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 08/07/2022.
//

import Foundation

final class StoreViewModel {

    private let appDependencies: AppDependencies
    private weak var flowController: BookingFlowController?

    init(
        appDependencies: AppDependencies,
        flowController: BookingFlowController,
        initialServices: [String],
        initialProducts: [String],
        goStraightToCheckout: Bool
    ) {
        self.appDependencies = appDependencies
        self.flowController = flowController
    }
}
