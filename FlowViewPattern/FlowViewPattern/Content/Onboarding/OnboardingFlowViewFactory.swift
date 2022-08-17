//
//  OnboardingFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 01/08/2022.
//

import Foundation

protocol OnboardingFlowViewFactory {
    func makeWelcomeView() -> WelcomeView
    func makeGetStartedView(with flowCoordinator: OnboardingFlowCoordinator) -> GetStartedView
}

extension DefaultAppFlowViewFactory: OnboardingFlowViewFactory {
    func makeWelcomeView() -> WelcomeView {
        WelcomeView()
    }
    func makeGetStartedView(with flowCoordinator: OnboardingFlowCoordinator) -> GetStartedView {
        GetStartedView(
            viewModel: .init(
                flowCoordinator: flowCoordinator,
                appDependencies: self.appDependencies
            )
        )
    }
}
