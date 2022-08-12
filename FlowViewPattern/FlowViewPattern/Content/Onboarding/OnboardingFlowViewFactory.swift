//
//  OnboardingFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 01/08/2022.
//

import Foundation

protocol OnboardingFlowViewFactory {
    func makeOnboardingView(with flowCoordinator: OnboardingFlowCoordinator) -> OnboardingView
}

extension DefaultAppFlowViewFactory: OnboardingFlowViewFactory {
    func makeOnboardingView(with flowCoordinator: OnboardingFlowCoordinator) -> OnboardingView {
        OnboardingView(
            viewModel: .init(
                flowCoordinator: flowCoordinator,
                appDependencies: self.appDependencies
            )
        )
    }
}
