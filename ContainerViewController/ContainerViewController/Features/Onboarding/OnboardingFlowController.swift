//
//  OnboardingFlowController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit

protocol OnboardingFlowController: AnyObject {
    func completedOnboarding()
}

final class DefaultOnboardingFlowController: UINavigationController {

    private let appDependencies: AppDependencies

    weak var flowController: SceneFlowController?

    init(appDependencies: AppDependencies, flowController: SceneFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let onboardingViewController = OnboardingViewController(
            viewModel: OnboardingViewModel(appDependencies: appDependencies, flowController: self)
        )
        setViewControllers([onboardingViewController], animated: false)
    }
}

extension DefaultOnboardingFlowController: OnboardingFlowController {

    func completedOnboarding() {
        flowController?.completedOnboarding()
    }
}
