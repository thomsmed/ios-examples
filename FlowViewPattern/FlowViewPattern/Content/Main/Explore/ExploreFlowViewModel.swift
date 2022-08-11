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

    private weak var flowCoordinator: MainFlowCoordinator?

    init(flowCoordinator: MainFlowCoordinator) {
        self.flowCoordinator = flowCoordinator
    }

    @Published var pageStack: [Page] = []
}

extension ExploreFlowViewModel: ExploreFlowCoordinator {

    func continueToBooking() {
        flowCoordinator?.presentBooking()
    }

    func continueToNews() {
        pageStack.append(.news)
    }
}

extension ExploreFlowViewModel: ExploreFlowViewFactory {

    func makeMapAndListFlowView() -> MapAndListFlowView {
        MapAndListFlowView()
    }

    func makeExploreNewsView() -> ExploreNewsView {
        ExploreNewsView()
    }
}
