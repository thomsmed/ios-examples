//
//  OnboardingViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class OnboardingViewModel: ObservableObject {

    private weak var flowCoordinator: OnboardingFlowCoordinator?
    private let appDependencies: AppDependencies

    init(flowCoordinator: OnboardingFlowCoordinator, appDependencies: AppDependencies) {
        self.flowCoordinator = flowCoordinator
        self.appDependencies = appDependencies
    }
}

extension OnboardingViewModel {

    func completeOnboarding() {
        appDependencies.defaultsRepository.set(true, for: .onboardingCompleted)
        flowCoordinator?.onboardingComplete()
    }
}
