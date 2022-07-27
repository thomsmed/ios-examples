//
//  DefaultAppFlowFactory.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 13/07/2022.
//

import Foundation

final class DefaultAppFlowFactory {

    internal let appDependencies: AppDependencies

    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
    }
}

extension DefaultAppFlowFactory: AppFlowFactory {

    func makePrimarySceneFlowHost(with flowController: AppFlowController) -> PrimarySceneFlowHost {
        DefaultPrimarySceneFlowHost(
            flowFactory: self,
            flowController: flowController
        )
    }
}
