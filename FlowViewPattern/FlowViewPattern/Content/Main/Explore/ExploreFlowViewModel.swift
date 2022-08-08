//
//  ExploreFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

final class ExploreFlowViewModel: ObservableObject {

    private weak var flowCoordinator: MainFlowCoordinator?

    init(flowCoordinator: MainFlowCoordinator) {
        self.flowCoordinator = flowCoordinator

        // TODO: Restore path?

    }

    @Published var path = NavigationPath()
}

extension ExploreFlowViewModel: ExploreFlowCoordinator {

    func continueToBooking() {
        flowCoordinator?.presentBooking()
    }

    func continueToNews() {
        //path.append()
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
