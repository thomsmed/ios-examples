//
//  LoginFlowController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit

protocol LoginFlowController: AnyObject {
    func signedIn()
}

final class DefaultLoginFlowController: UINavigationController {

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

        let loginViewController = LoginViewController(
            viewModel: LoginViewModel(appDependencies: appDependencies, flowController: self)
        )
        setViewControllers([loginViewController], animated: false)
    }
}

extension DefaultLoginFlowController: LoginFlowController {

    func signedIn() {
        flowController?.signedIn()
    }
}
