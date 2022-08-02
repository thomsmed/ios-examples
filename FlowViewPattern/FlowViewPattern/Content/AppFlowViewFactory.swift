//
//  AppFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

protocol AppFlowViewFactory: AnyObject {
    func makeOnboardingFlowView() -> OnboardingFlowView
    func makeMainFlowView() -> MainFlowView
}
