//
//  ExploreFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct ExploreFlowView: View {

    @StateObject var flowViewModel: ExploreFlowViewModel
    let flowViewFactory: ExploreFlowViewFactory

    var body: some View {
        NavigationStack(path: $flowViewModel.pageStack) {
            flowViewFactory.makeMapAndListFlowView(
                with: flowViewModel
            )
            .navigationDestination(for: Page.self) { page in
                switch page {
                case .mapAndList:
                    flowViewFactory.makeMapAndListFlowView(
                        with: flowViewModel
                    )
                case .news:
                    flowViewFactory.makeExploreNewsView()
                }
            }
        }
        .onOpenURL { url in
            guard
                let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
                let appPage: AppPage = .from(urlComponents),
                let page = appPage.asMainPage()?.asExplorePage()
            else {
                return
            }

            flowViewModel.go(to: page)
        }
    }
}

extension AppPage.Main {
    func asExplorePage() -> AppPage.Main.Explore? {
        switch self {
        case let .explore(page):
            return page
        default:
            return nil
        }
    }
}

extension ExploreFlowView {
    enum Page {
        case mapAndList
        case news
    }
}

struct ExploreFlowView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreFlowView(
            flowViewModel: .init(
                flowCoordinator: PreviewFlowCoordinator.shared,
                currentPage: .explore(page: .store(page: .map()))
            ),
            flowViewFactory: PreviewFlowViewFactory.shared
        )
    }
}
