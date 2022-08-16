//
//  AppFlowCoordinator.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation
import Combine

protocol AppFlowCoordinator: AnyObject {
    func onboardingCompleteContinueToMain()
}

extension PreviewFlowCoordinator: AppFlowCoordinator {
    func onboardingCompleteContinueToMain() {}
}
