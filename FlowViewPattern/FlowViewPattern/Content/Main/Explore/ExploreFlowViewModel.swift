//
//  ExploreFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

final class ExploreFlowViewModel: ObservableObject {

    enum Page {
        case mapAndList
        case news
    }

    @Published var pageStack: [Page] = []

    private weak var flowCoordinator: MainFlowCoordinator?

    init(flowCoordinator: MainFlowCoordinator) {
        self.flowCoordinator = flowCoordinator
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
