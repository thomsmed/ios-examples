//
//  OnboardingFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class OnboardingFlowViewModel: ObservableObject {

    private weak var flowCoordinator: AppFlowCoordinator?
    private let appDependencies: AppDependencies

    init(flowCoordinator: AppFlowCoordinator, appDependencies: AppDependencies) {
        self.flowCoordinator = flowCoordinator
        self.appDependencies = appDependencies
    }
}

extension OnboardingFlowViewModel: OnboardingFlowCoordinator {

    func onboardingComplete() {
        flowCoordinator?.onboardingCompleteContinueToMain()
    }
}


extension OnboardingFlowViewModel: OnboardingViewFactory {

    func makeOnboardingView() -> OnboardingView {
        OnboardingView(
            viewModel: .init(
                flowCoordinator: self,
                appDependencies: self.appDependencies
            )
        )
    }
}
