//
//  OnboardingViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 01/08/2022.
//

import Foundation

protocol OnboardingViewFactory: AnyObject {

    func makeOnboardingView() -> OnboardingView
}
