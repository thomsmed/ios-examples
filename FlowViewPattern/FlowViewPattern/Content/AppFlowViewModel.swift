//
//  AppFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation
import Combine

final class AppFlowViewModel: ObservableObject {

    @Published var selectedPage: AppFlowView.Page

    init(appDependencies: AppDependencies) {
        let onboardingCompleted = appDependencies.defaultsRepository.bool(for: .onboardingCompleted)
        selectedPage = onboardingCompleted
            ? .main()
            : .onboarding
    }

    func go(to path: AppPath) {
        if case let .main(subPath) = path {
            selectedPage = .main(subPath)
        }
    }
}

// MARK: AppFlowCoordinator

extension AppFlowViewModel: AppFlowCoordinator {

    func onboardingCompleteContinueToMain() {
        selectedPage = .main()
    }
}
