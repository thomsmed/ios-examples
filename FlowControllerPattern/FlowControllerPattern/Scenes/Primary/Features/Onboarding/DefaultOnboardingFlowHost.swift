//
//  DefaultOnboardingFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

final class DefaultOnboardingFlowHost: SinglePageController {

    private let appDependencies: AppDependencies
    private weak var flowController: PrimarySceneFlowController?

    init(appDependencies: AppDependencies, flowController: PrimarySceneFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultOnboardingFlowHost: OnboardingFlowHost {

    func start(_ page: PrimaryPage.Onboarding) {
        let onboardingViewController = OnboardingViewController(
            viewModel: OnboardingViewModel(
                appDependencies: appDependencies,
                flowController: self
            )
        )
        setViewController(onboardingViewController, using: .none)
    }

    func go(to page: PrimaryPage.Onboarding) {
        
    }
}

extension DefaultOnboardingFlowHost {

    func onboardingComplete(continueTo mainPage: PrimaryPage.Main) {
        flowController?.onboardingComplete(continueTo: mainPage)
    }
}
