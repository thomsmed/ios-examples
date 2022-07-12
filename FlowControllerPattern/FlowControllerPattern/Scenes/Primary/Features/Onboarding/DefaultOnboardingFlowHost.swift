//
//  DefaultOnboardingFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

final class DefaultOnboardingFlowHost: SinglePageController {

    private let flowFactory: OnboardingFlowFactory
    private weak var flowController: PrimarySceneFlowController?

    init(flowFactory: OnboardingFlowFactory, flowController: PrimarySceneFlowController) {
        self.flowFactory = flowFactory
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultOnboardingFlowHost: OnboardingFlowHost {

    func start(_ page: PrimaryPage.Onboarding) {
        let onboardingViewHolder = flowFactory.makeOnboardingViewHolder(with: self)
        setViewController(onboardingViewHolder, using: .none)
    }

    func go(to page: PrimaryPage.Onboarding) {
        
    }
}

extension DefaultOnboardingFlowHost {

    func onboardingComplete(continueTo mainPage: PrimaryPage.Main) {
        flowController?.onboardingComplete(continueTo: mainPage)
    }
}
