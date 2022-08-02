//
//  AppFlowCoordinator.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

protocol AppFlowCoordinator: AnyObject {
    func onboardingCompleteContinueToMain()
}

extension DummyFlowCoordinator: AppFlowCoordinator {

    func onboardingCompleteContinueToMain() {
        
    }
}
