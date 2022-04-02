//
//  OnboardingFlowController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit

protocol OnboardingFlowController: AnyObject {

}

final class DefaultOnboardingFlowController: UINavigationController {

    private let appDependencies: AppDependencies

    weak var flowController: AppFlowController?

    init(appDependencies: AppDependencies, flowController: AppFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewControllers([OnboardingViewController()], animated: false)
    }
}
