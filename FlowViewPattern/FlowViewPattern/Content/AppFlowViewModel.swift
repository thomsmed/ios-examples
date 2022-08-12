//
//  AppFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class AppFlowViewModel: ObservableObject {

    @Published var onboardingComplete: Bool

    init(appDependencies: AppDependencies) {
        onboardingComplete = appDependencies.defaultsRepository.getBool(for: .onboardingCompleted)
    }
}

// MARK: AppFlowCoordinator

extension AppFlowViewModel: AppFlowCoordinator {

    func onboardingCompleteContinueToMain() {
        onboardingComplete = true
    }
}
