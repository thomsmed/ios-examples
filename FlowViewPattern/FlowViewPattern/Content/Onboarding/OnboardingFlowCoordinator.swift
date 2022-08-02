//
//  OnboardingFlowCoordinator.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

protocol OnboardingFlowCoordinator: AnyObject {
    func onboardingComplete()
}

extension DummyFlowCoordinator: OnboardingFlowCoordinator {

    func onboardingComplete() {
        
    }
}
