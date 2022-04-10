//
//  OnboardingViewModel.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
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

    func completeOnboarding() {
        // Wrap up onboarding etc, then:
        flowController?.completedOnboarding()
    }
}
