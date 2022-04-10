//
//  ProfileViewModel.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import Foundation

final class ProfileViewModel {

    private let appDependencies: AppDependencies

    private weak var flowController: ProfileFlowController?

    init(appDependencies: AppDependencies, flowController: ProfileFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController
    }
}

extension ProfileViewModel {

    func signOut() {
        // Sign out etc, then:
        flowController?.signedOut()
    }
}
