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
                case .news:
                    flowViewFactory.makeExploreNewsView()
                default:
                    EmptyView()
                }
            }
        }
        .onOpenURL { url in
            guard let path = AppPath.Main.Explore(url) else {
                return
            }

            flowViewModel.go(to: path)
        }
    }
}

extension ExploreFlowView {
    enum Page {
        case mapAndList
        case news
    }
}

extension AppPath.Main.Explore {
    init?(_ url: URL) {
        guard
            let mainPath = AppPath.Main(url),
            case let .explore(subPath) = mainPath
        else {
            return nil
        }

        self = subPath
    }
}

struct ExploreFlowView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreFlowView(
            flowViewModel: .init(
                flowCoordinator: PreviewFlowCoordinator.shared
            ),
            flowViewFactory: PreviewFlowViewFactory.shared
        )
    }
}
