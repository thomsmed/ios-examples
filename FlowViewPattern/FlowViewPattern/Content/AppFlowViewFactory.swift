//
//  AppFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

protocol AppFlowViewFactory {
    func makeOnboardingFlowView(with flowCoordinator: AppFlowCoordinator) -> OnboardingFlowView
    func makeMainFlowView(with flowCoordinator: AppFlowCoordinator) -> MainFlowView
}

extension DefaultAppFlowViewFactory: AppFlowViewFactory {
    func makeOnboardingFlowView(with flowCoordinator: AppFlowCoordinator) -> OnboardingFlowView {
        OnboardingFlowView(
            flowViewModel: .init(
                flowCoordinator: flowCoordinator
            ),
            flowViewFactory: self
        )
    }

    func makeMainFlowView(with flowCoordinator: AppFlowCoordinator) -> MainFlowView {
        MainFlowView(
            flowViewModel: .init(
                flowCoordinator: flowCoordinator,
                appDependencies: self.appDependencies
            ),
            flowViewFactory: self
        )
    }
}
