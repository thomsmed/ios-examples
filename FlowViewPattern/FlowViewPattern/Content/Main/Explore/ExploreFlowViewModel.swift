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

    private(set) var currentExplorePage: AppPage.Main.Explore {
        didSet {
            explorePageSubject.send(currentExplorePage)
        }
    }

    private let explorePageSubject = PassthroughSubject<AppPage.Main.Explore, Never>()

    private weak var flowCoordinator: MainFlowCoordinator?

    private var mainPageSubscription: AnyCancellable?

    init(flowCoordinator: MainFlowCoordinator) {
        self.flowCoordinator = flowCoordinator

        switch flowCoordinator.currentMainPage {
        case let .explore(page):
            self.currentExplorePage = page
        default:
            self.currentExplorePage = .store(page: .map())
        }

        mainPageSubscription = flowCoordinator.mainPage
            .compactMap { mainPage in
                if case let .explore(explorePage) = mainPage {
                    return explorePage
                }
                return nil
            }
            .sink { [weak self] explorePage in
                self?.currentExplorePage = explorePage

                switch explorePage {
                case .store:
                    self?.pageStack = []
                case .news:
                    self?.pageStack.append(.news)
                }
            }
    }
}

extension ExploreFlowViewModel: ExploreFlowCoordinator {

    var explorePage: AnyPublisher<AppPage.Main.Explore, Never> {
        explorePageSubject.eraseToAnyPublisher()
    }

    func continueToBooking() {
        flowCoordinator?.presentBooking()
    }

    func continueToNews() {
        currentExplorePage = .news
        pageStack.append(.news)
    }
}
