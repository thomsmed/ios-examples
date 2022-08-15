//
//  AppFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Combine

final class AppFlowViewModel: ObservableObject {

    @Published var selectedPage: AppFlowView.Page

    private(set) var currentPage: AppPage

    init(appDependencies: AppDependencies) {
        let onboardingCompleted = appDependencies.defaultsRepository.bool(for: .onboardingCompleted)
        selectedPage = onboardingCompleted
            ? .main
            : .onboarding
        currentPage = onboardingCompleted
            ? .main(page: .explore(page: .store(page: .map())))
            : .onboarding(page: .welcome)
    }

    func go(to page: AppPage) {
        currentPage = page

        if case .main = page {
            selectedPage = .main
        }
    }
}

// MARK: AppFlowCoordinator

extension AppFlowViewModel: AppFlowCoordinator {

    func onboardingCompleteContinueToMain() {
        selectedPage = .main
    }
}
