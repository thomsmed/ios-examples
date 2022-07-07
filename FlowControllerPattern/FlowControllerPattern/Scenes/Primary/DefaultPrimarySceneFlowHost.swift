//
//  DefaultPrimarySceneFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

final class DefaultPrimarySceneFlowHost: SinglePageController {

    private weak var flowController: AppFlowController?

    init(appDependencies: AppDependencies, flowController: AppFlowController) {
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultPrimarySceneFlowHost: PrimarySceneFlowHost {

    func start(_ page: PrimaryScenePage) {
        switch page {
        case let .onboarding(page):
            let onboardingFlowHost = DefaultOnboardingFlowHost()
            onboardingFlowHost.start(page)
            setViewController(onboardingFlowHost, using: .none)
        case let .main(page):
            let mainFlowHost = DefaultMainFlowHost()
            mainFlowHost.start(page)
            setViewController(mainFlowHost, using: .none)
        }
    }

    func go(to page: PrimaryScenePage) {
        switch page {
        case let .onboarding(page):
            if let onboardingFlowHost = viewController as? OnboardingFlowHost {
                onboardingFlowHost.go(to: page)
            } else {
                let onboardingFlowHost = DefaultOnboardingFlowHost()
                onboardingFlowHost.start(page)
                setViewController(onboardingFlowHost, using: .dissolve)
            }
        case let .main(page):
            if let mainFlowHost = viewController as? MainFlowHost {
                mainFlowHost.go(to: page)
            } else {
                let mainFlowHost = DefaultMainFlowHost()
                mainFlowHost.start(page)
                setViewController(mainFlowHost, using: .flip)
            }
        }
    }

    func sceneWillResignActive() {

    }

    func sceneWillEnterForeground() {

    }

    func open(_ urlContexts: Set<UIOpenURLContext>) {

    }

    func sceneDidBecomeActive() {

    }

    func sceneDidEnterBackground() {

    }
}
