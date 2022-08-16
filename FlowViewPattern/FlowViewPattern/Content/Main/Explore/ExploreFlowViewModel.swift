//
//  ExploreFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI
import Combine

final class ExploreFlowViewModel: ObservableObject {

    @Published var pageStack: [ExploreFlowView.Page] = []

    private weak var flowCoordinator: MainFlowCoordinator?

    init(flowCoordinator: MainFlowCoordinator) {
        self.flowCoordinator = flowCoordinator
    }

    func go(to path: AppPath.Main.Explore) {
        switch path {
        case let .store(subPath):
            pageStack.removeAll()
        case .news:
            pageStack.append(.news)
        }
    }
}

extension ExploreFlowViewModel: ExploreFlowCoordinator {

    func continueToBooking() {
        flowCoordinator?.presentBooking()
    }

    func continueToNews() {
        pageStack.append(.news)
    }
}
