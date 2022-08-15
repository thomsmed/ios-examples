//
//  AppFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

protocol AppFlowViewFactory {
    func makeOnboardingFlowView(with flowCoordinator: AppFlowCoordinator, at currentPage: AppPage) -> OnboardingFlowView
    func makeMainFlowView(with flowCoordinator: AppFlowCoordinator, at currentPage: AppPage) -> MainFlowView
}

extension DefaultAppFlowViewFactory: AppFlowViewFactory {
    func makeOnboardingFlowView(with flowCoordinator: AppFlowCoordinator, at currentPage: AppPage) -> OnboardingFlowView {
        OnboardingFlowView(
            flowViewModel: .init(
                flowCoordinator: flowCoordinator
            ),
            flowViewFactory: self
        )
    }

    func makeMainFlowView(with flowCoordinator: AppFlowCoordinator, at currentPage: AppPage) -> MainFlowView {
        MainFlowView(
            flowViewModel: .init(
                flowCoordinator: flowCoordinator,
                appDependencies: self.appDependencies,
                currentPage: currentPage
            ),
            flowViewFactory: self
        )
    }
}
