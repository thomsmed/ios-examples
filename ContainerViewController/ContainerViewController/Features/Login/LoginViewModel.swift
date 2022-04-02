//
//  LoginViewModel.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import Foundation

final class LoginViewModel {

    private let appDependencies: AppDependencies

    private weak var flowController: LoginFlowController?

    init(appDependencies: AppDependencies, flowController: LoginFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController
    }
}

extension LoginViewModel {

    func signIn() {
        // Sign in etc, then:
        flowController?.signedIn()
    }
}
