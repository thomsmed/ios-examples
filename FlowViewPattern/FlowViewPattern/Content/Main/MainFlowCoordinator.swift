//
//  MainFlowCoordinator.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation
import Combine

protocol MainFlowCoordinator: AnyObject {
    var currentMainPage: AppPage.Main { get }
    var mainPage: AnyPublisher<AppPage.Main, Never> { get }
    func presentBooking()
}

extension PreviewFlowCoordinator: MainFlowCoordinator {

    var currentMainPage: AppPage.Main {
        .explore(page: .store(page: .map()))
    }

    var mainPage: AnyPublisher<AppPage.Main, Never> {
        Empty().eraseToAnyPublisher()
    }

    func presentBooking() {
        
    }
}
