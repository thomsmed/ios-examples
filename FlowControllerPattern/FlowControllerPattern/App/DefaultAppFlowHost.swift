//
//  DefaultAppFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

final class DefaultAppFlowHost {

    private let flowFactory: AppFlowFactory

    private var flowHostsByScene: [UIScene: PrimarySceneFlowHost] = [:]

    private var launchOptions: [UIApplication.LaunchOptionsKey : Any]?

    init(flowFactory: AppFlowFactory) {
        self.flowFactory = flowFactory
    }
}

extension DefaultAppFlowHost: AppFlowHost {

    func applicationDidFinishLaunchingWith(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.launchOptions = launchOptions
    }

    func flowHost(for scene: UIScene) -> PrimarySceneFlowHost {
        if let flowHost = flowHostsByScene[scene] {
            return flowHost
        }

        let flowHost = flowFactory.makePrimarySceneFlowHost(with: self)

        flowHostsByScene[scene] = flowHost

        return flowHost
    }

    func discardFlowHost(for scene: UIScene) {
        flowHostsByScene[scene] = nil
    }
}
