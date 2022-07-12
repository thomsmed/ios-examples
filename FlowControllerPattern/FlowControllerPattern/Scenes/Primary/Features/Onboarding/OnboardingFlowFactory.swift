//
//  OnboardingFlowFactory.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 13/07/2022.
//

import Foundation

protocol OnboardingFlowFactory: AnyObject {
    func makeOnboardingViewHolder(with flowController: OnboardingFlowController) -> OnboardingViewHolder
}

extension DefaultAppFlowFactory: OnboardingFlowFactory {

    func makeOnboardingViewHolder(with flowController: OnboardingFlowController) -> OnboardingViewHolder {
        OnboardingViewController(
            viewModel: OnboardingViewModel(
                flowController: flowController,
                analytics: appDependencies.analytics
            )
        )
    }
}
