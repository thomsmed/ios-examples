//
//  DefaultPrimarySceneFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

final class DefaultPrimarySceneFlowHost: SinglePageController {

    private let flowFactory: PrimarySceneFlowFactory
    private weak var flowController: AppFlowController?

    init(flowFactory: PrimarySceneFlowFactory, flowController: AppFlowController) {
        self.flowFactory = flowFactory
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultPrimarySceneFlowHost: PrimarySceneFlowHost {

    func start(_ page: AppPage.Primary) {
        switch page {
        case let .onboarding(page):
            let onboardingFlowHost = flowFactory.makeOnboardingFlowHost(with: self)
            onboardingFlowHost.start(page)
            setViewController(onboardingFlowHost, using: .none)
        case let .main(page):
            let mainFlowHost = flowFactory.makeMainFlowHost(with: self)
            mainFlowHost.start(page)
            setViewController(mainFlowHost, using: .none)
        }
    }

    func go(to page: AppPage.Primary) {
        switch page {
        case let .onboarding(page):
            if let onboardingFlowHost = viewController as? OnboardingFlowHost {
                onboardingFlowHost.go(to: page)
            } else {
                let onboardingFlowHost = flowFactory.makeOnboardingFlowHost(with: self)
                onboardingFlowHost.start(page)
                setViewController(onboardingFlowHost, using: .dissolve)
            }
        case let .main(page):
            if let mainFlowHost = viewController as? MainFlowHost {
                mainFlowHost.go(to: page)
            } else {
                let mainFlowHost = flowFactory.makeMainFlowHost(with: self)
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

    func onboardingComplete(continueTo mainPage: AppPage.Primary.Main) {
        go(to: .main(page: mainPage))
    }
}
