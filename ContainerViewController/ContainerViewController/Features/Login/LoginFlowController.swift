//
//  LoginFlowController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit

protocol LoginFlowController: AnyObject {
    func register()
    func signedIn()
}

final class DefaultLoginFlowController: UINavigationController {

    private let appDependencies: AppDependencies

    private weak var flowController: SceneFlowController?

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

        let loginViewController = LoginViewController(
            viewModel: LoginViewModel(appDependencies: appDependencies, flowController: self)
        )
        setViewControllers([loginViewController], animated: false)
    }
}

extension DefaultLoginFlowController: LoginFlowController {

    func register() {
        let registerViewController = RegisterViewController(
            viewModel: RegisterViewModel(appDependencies: appDependencies, flowController: self)
        )
        pushViewController(registerViewController, animated: true)
    }

    func signedIn() {
        flowController?.signedIn()
    }
}
