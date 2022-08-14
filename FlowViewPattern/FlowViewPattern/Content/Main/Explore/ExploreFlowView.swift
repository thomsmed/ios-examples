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
            .navigationDestination(for: ExploreFlowViewModel.Page.self) { page in
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
