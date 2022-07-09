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

    func makeFlowHost(for scene: UIScene) -> PrimarySceneFlowHost {
        let sceneFlowHost = DefaultPrimarySceneFlowHost(
            appDependencies: appDependencies, flowController: self
        )

        flowHostsByScene[scene] = sceneFlowHost

        return sceneFlowHost
    }

    func discardFlowHost(for scene: UIScene) {
        flowHostsByScene[scene] = nil
    }
}
