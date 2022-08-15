//
//  ExploreFlowCoordinator.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation
import Combine

protocol ExploreFlowCoordinator: AnyObject {
    var currentExplorePage: AppPage.Main.Explore { get }
    var explorePage: AnyPublisher<AppPage.Main.Explore, Never> { get }
    func continueToNews()
    func continueToBooking()
}

extension PreviewFlowCoordinator: ExploreFlowCoordinator {

    var currentExplorePage: AppPage.Main.Explore {
        .store(page: .map())
    }

    var explorePage: AnyPublisher<AppPage.Main.Explore, Never> {
        Empty().eraseToAnyPublisher()
    }

    func continueToNews() {
        
    }

    func continueToBooking() {
        
    }
}
