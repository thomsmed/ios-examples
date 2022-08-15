//
//  ExploreFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

final class ExploreFlowViewModel: ObservableObject {

    @Published var pageStack: [ExploreFlowView.Page] = []

    private(set) var currentPage: AppPage.Main.Explore

    private weak var flowCoordinator: MainFlowCoordinator?

    init(flowCoordinator: MainFlowCoordinator, currentPage: AppPage.Main) {
        self.flowCoordinator = flowCoordinator

        switch currentPage {
        case let .explore(page):
            self.currentPage = page
        default:
            self.currentPage = .store(page: .map())
        }
    }

    func go(to page: AppPage.Main.Explore) {
        currentPage = page

        switch page {
        case .store:
            pageStack = []
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
        currentPage = .news
        pageStack.append(.news)
    }
}
