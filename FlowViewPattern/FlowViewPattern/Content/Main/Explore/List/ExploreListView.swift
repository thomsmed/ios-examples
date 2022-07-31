//
//  ExploreListView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct ExploreListView: View {

    @StateObject var viewModel: ExploreListViewModel

    var body: some View {
        Text("Explore list view")
    }
}

struct ExploreListView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreListView(
            viewModel: .init(
                flowCoordinator: DummyFlowCoordinator.shared,
                appDependencies: DummyAppDependencies.shared
            )
        )
    }
}
