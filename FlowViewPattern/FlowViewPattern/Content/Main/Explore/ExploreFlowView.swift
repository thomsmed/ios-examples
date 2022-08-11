//
//  ExploreFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct ExploreFlowView: View {

    @StateObject var flowViewModel: ExploreFlowViewModel

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack(path: $flowViewModel.pageStack) {
            flowViewModel.makeMapAndListFlowView()
                .navigationDestination(for: ExploreFlowViewModel.Page.self) { page in
                    switch page {
                    case .mapAndList:
                        flowViewModel.makeMapAndListFlowView()
                    case .news:
                        flowViewModel.makeExploreNewsView()
                    }
                }
        }
        .onChange(of: scenePhase) { scenePhase in
            if scenePhase == .background {
                // TODO: Save path? How to save View state?
            }
        }
    }
}

struct ExploreFlowView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreFlowView(
            flowViewModel: .init(
                flowCoordinator: MockFlowCoordinator.shared
            )
        )
    }
}
