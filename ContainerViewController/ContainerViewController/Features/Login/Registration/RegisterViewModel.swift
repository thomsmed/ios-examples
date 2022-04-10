//
//  RegisterViewModel.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 10/04/2022.
//

import Foundation

final class RegisterViewModel {

    private let appDependencies: AppDependencies

    private weak var flowController: LoginFlowController?

    init(appDependencies: AppDependencies, flowController: LoginFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController
    }
}

extension RegisterViewModel {

    func register() {
        // Register etc, then:
        flowController?.signedIn()
    }
}
