//
//  PrimarySceneFlowFactory.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 13/07/2022.
//

import Foundation

protocol PrimarySceneFlowFactory: AnyObject {
    func makeOnboardingFlowHost(with flowController: PrimarySceneFlowController) -> OnboardingFlowHost
    func makeMainFlowHost(with flowController: PrimarySceneFlowController) -> MainFlowHost
}

extension DefaultAppFlowFactory: PrimarySceneFlowFactory {

    func makeOnboardingFlowHost(with flowController: PrimarySceneFlowController) -> OnboardingFlowHost {
        DefaultOnboardingFlowHost(
            flowFactory: self,
            flowController: flowController
        )
    }

    func makeMainFlowHost(with flowController: PrimarySceneFlowController) -> MainFlowHost {
        DefaultMainFlowHost(flowFactory: self)
    }
}
