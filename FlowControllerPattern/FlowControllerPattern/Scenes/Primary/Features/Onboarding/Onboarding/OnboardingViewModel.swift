//
//  OnboardingViewModel.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 09/07/2022.
//

import Foundation

final class OnboardingViewModel {

    private weak var flowController: OnboardingFlowController?

    private let analytics: AnalyticsLogger

    init(flowController: OnboardingFlowController, analytics: AnalyticsLogger) {
        self.flowController = flowController
        self.analytics = analytics
    }
}

extension OnboardingViewModel {

    func goNext() {
        analytics.set(.hasCompletedOnboarding(value: true))
        flowController?.onboardingComplete(continueTo: .explore(page: .store(page: .map(page: nil, storeId: nil))))
    }
}
