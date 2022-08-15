//
//  AppFlowCoordinator.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation
import Combine

protocol AppFlowCoordinator: AnyObject {
    var currentAppPage: AppPage { get }
    var appPage: AnyPublisher<AppPage, Never> { get }
    func onboardingCompleteContinueToMain()
}

extension PreviewFlowCoordinator: AppFlowCoordinator {

    var currentAppPage: AppPage {
        .main(page: .explore(page: .store(page: .map())))
    }

    var appPage: AnyPublisher<AppPage, Never> {
        Empty().eraseToAnyPublisher()
    }

    func onboardingCompleteContinueToMain() {
        
    }
}
