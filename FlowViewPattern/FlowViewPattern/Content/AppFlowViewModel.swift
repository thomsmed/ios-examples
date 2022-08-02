//
//  AppFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class AppFlowViewModel: ObservableObject {

    let appDependencies: AppDependencies

    @Published var onboardingComplete: Bool

    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies

        onboardingComplete = appDependencies.defaultsRepository.getBool(for: .onboardingCompleted)
    }
}

extension AppFlowViewModel: AppFlowCoordinator {

    func onboardingCompleteContinueToMain() {
        onboardingComplete = true
    }
}

extension AppFlowViewModel: AppFlowViewFactory {

    func makeOnboardingFlowView() -> OnboardingFlowView {
        OnboardingFlowView(
            flowViewModel: .init(
                flowCoordinator: self,
                appDependencies: self.appDependencies
            )
        )
    }

    func makeMainFlowView() -> MainFlowView {
        MainFlowView(
            flowViewModel: .init(
                flowCoordinator: self,
                appDependencies: self.appDependencies
            )
        )
    }
}
