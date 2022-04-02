//
//  AppFlowController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit

protocol AppFlowController: AnyObject {
    func signedOut()
    func signedIn()
    func completedOnboarding()
}

final class DefaultAppFlowController: CustomContainerViewController {

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

        setViewController(onboardingFlowController, with: .none)
    }

    private func configureAppearance() {
        UINavigationBar.appearance().tintColor = .label
        UITabBar.appearance().tintColor = .label
        UIButton.appearance().tintColor = .label
    }
}

extension DefaultAppFlowController: AppFlowController {

    func signedOut() {
        setViewController(loginFlowController, with: .flip)
    }

    func signedIn() {
        setViewController(mainFlowController, with: .flip)
    }

    func completedOnboarding() {
        setViewController(loginFlowController, with: .dissolve)
    }
}
