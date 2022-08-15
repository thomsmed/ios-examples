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

    private(set) var currentAppPage: AppPage {
        didSet {
            appPageSubject.send(currentAppPage)
        }
    }

    private let appPageSubject = PassthroughSubject<AppPage, Never>()

    init(appDependencies: AppDependencies) {
        let onboardingCompleted = appDependencies.defaultsRepository.bool(for: .onboardingCompleted)
        selectedPage = onboardingCompleted
            ? .main
            : .onboarding
        currentAppPage = onboardingCompleted
            ? .main(page: .explore(page: .store(page: .map())))
            : .onboarding(page: .welcome)
    }

    func go(to page: AppPage) {
        currentAppPage = page

        if case .main = page {
            selectedPage = .main
        }
    }
}

// MARK: AppFlowCoordinator

extension AppFlowViewModel: AppFlowCoordinator {

    var appPage: AnyPublisher<AppPage, Never> {
        appPageSubject.eraseToAnyPublisher()
    }

    func onboardingCompleteContinueToMain() {
        selectedPage = .main
    }
}
