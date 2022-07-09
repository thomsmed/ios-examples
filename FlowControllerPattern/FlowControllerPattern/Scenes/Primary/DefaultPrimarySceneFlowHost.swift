//
//  DefaultPrimarySceneFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

final class DefaultPrimarySceneFlowHost: SinglePageController {

    private let appDependencies: AppDependencies
    private weak var flowController: AppFlowController?

    init(appDependencies: AppDependencies, flowController: AppFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultPrimarySceneFlowHost: PrimarySceneFlowHost {

    func start(_ page: PrimaryPage) {
        switch page {
        case let .onboarding(page):
            let onboardingFlowHost = DefaultOnboardingFlowHost(
                appDependencies: appDependencies, flowController: self
            )
            onboardingFlowHost.start(page)
            setViewController(onboardingFlowHost, using: .none)
        case let .main(page):
            let mainFlowHost = DefaultMainFlowHost(appDependencies: appDependencies)
            mainFlowHost.start(page)
            setViewController(mainFlowHost, using: .none)
        }
    }

    func go(to page: PrimaryPage) {
        switch page {
        case let .onboarding(page):
            if let onboardingFlowHost = viewController as? OnboardingFlowHost {
                onboardingFlowHost.go(to: page)
            } else {
                let onboardingFlowHost = DefaultOnboardingFlowHost(
                    appDependencies: appDependencies, flowController: self
                )
                onboardingFlowHost.start(page)
                setViewController(onboardingFlowHost, using: .dissolve)
            }
        case let .main(page):
            if let mainFlowHost = viewController as? MainFlowHost {
                mainFlowHost.go(to: page)
            } else {
                let mainFlowHost = DefaultMainFlowHost(appDependencies: appDependencies)
                mainFlowHost.start(page)
                setViewController(mainFlowHost, using: .flip)
            }
        }
    }

    func sceneWillResignActive() {

    }

    func sceneWillEnterForeground() {

    }

    func sceneDidBecomeActive() {

    }

    func sceneDidEnterBackground() {

    }
}

extension DefaultPrimarySceneFlowHost {

    func onboardingComplete(continueTo mainPage: PrimaryPage.Main) {
        go(to: .main(page: mainPage))
    }
}
