//
//  SceneFlowController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit

protocol SceneFlowController: AnyObject {
    func signedOut()
    func signedIn()
    func completedOnboarding()
}

final class DefaultSceneFlowController: LinearContainerViewController {

    private let appDependencies: AppDependencies

    private lazy var onboardingFlowController = DefaultOnboardingFlowController(
        appDependencies: appDependencies, flowController: self
    )
    private lazy var loginFlowController = DefaultLoginFlowController(
        appDependencies: appDependencies, flowController: self
    )
    private lazy var mainFlowController = DefaultMainFlowController(
        appDependencies: appDependencies, flowController: self
    )

    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
        super.init(nibName: nil, bundle: nil)
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewController(onboardingFlowController, using: .none)
    }

    private func configureAppearance() {
        UINavigationBar.appearance().tintColor = .label
        UITabBar.appearance().tintColor = .label
        UIButton.appearance().tintColor = .label
    }
}

extension DefaultSceneFlowController: SceneFlowController {

    func signedOut() {
        setViewController(loginFlowController, using: .flip)
    }

    func signedIn() {
        setViewController(mainFlowController, using: .flip)
    }

    func completedOnboarding() {
        setViewController(loginFlowController, using: .dissolve)
    }
}
