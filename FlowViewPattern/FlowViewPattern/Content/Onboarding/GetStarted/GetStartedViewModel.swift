//
//  GetStartedViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

struct GetStartedViewModel {

    private weak var flowCoordinator: OnboardingFlowCoordinator?
    private let defaultsRepository: DefaultsRepository

    init(flowCoordinator: OnboardingFlowCoordinator, appDependencies: AppDependencies) {
        self.flowCoordinator = flowCoordinator
        self.defaultsRepository = appDependencies.defaultsRepository
    }
}

extension GetStartedViewModel {

    func completeOnboarding() {
        defaultsRepository.set(true, for: .onboardingCompleted)
        flowCoordinator?.onboardingComplete()
    }
}
