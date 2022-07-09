//
//  OnboardingFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

protocol OnboardingFlowController: AnyObject {

}

protocol OnboardingFlowHost: OnboardingFlowController & UIViewController {
    func start(_ page: PrimaryPage.Onboarding)
    func go(to page: PrimaryPage.Onboarding)
}
