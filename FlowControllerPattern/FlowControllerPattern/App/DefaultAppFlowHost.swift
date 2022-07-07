//
//  DefaultAppFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

final class DefaultAppFlowHost {

    private let appDependencies: AppDependencies

    private(set) var flowHostsByScene: [UIScene: PrimarySceneFlowHost] = [:]

    private var launchOptions: [UIApplication.LaunchOptionsKey : Any]?

    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
    }
}

extension DefaultAppFlowHost: AppFlowHost {

    func applicationDidFinishLaunchingWith(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.launchOptions = launchOptions
    }

    func startAndReturnFlowHost(for scene: UIScene) -> PrimarySceneFlowHost {
        if let sceneFlowHost = flowHostsByScene[scene] {
            return sceneFlowHost
        }

        let sceneFlowHost = DefaultPrimarySceneFlowHost(
            appDependencies: appDependencies, flowController: self
        )
        sceneFlowHost.start(.onboarding(page: .home)) // TODO: Check launch options and pasteboard?

        flowHostsByScene[scene] = sceneFlowHost

        return sceneFlowHost
    }

    func discardFlowHost(for scene: UIScene) {
        flowHostsByScene[scene] = nil
    }
}
