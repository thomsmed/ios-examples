//
//  OnboardingViewModel.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 09/07/2022.
//

import Foundation

final class OnboardingViewModel {

    private let appDependencies: AppDependencies
    private weak var flowController: OnboardingFlowController?

    init(appDependencies: AppDependencies, flowController: OnboardingFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController
    }
}

extension OnboardingViewModel {

    func goNext() {
        flowController?.onboardingComplete(continueTo: .explore(page: .store(page: .map(page: nil, storeId: nil))))
    }
}
