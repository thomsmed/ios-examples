//
//  OnboardingFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class OnboardingFlowViewModel: ObservableObject {

    private weak var flowCoordinator: AppFlowCoordinator?

    init(flowCoordinator: AppFlowCoordinator) {
        self.flowCoordinator = flowCoordinator
    }
}

extension OnboardingFlowViewModel: OnboardingFlowCoordinator {

    func onboardingComplete() {
        flowCoordinator?.onboardingCompleteContinueToMain()
    }
}
