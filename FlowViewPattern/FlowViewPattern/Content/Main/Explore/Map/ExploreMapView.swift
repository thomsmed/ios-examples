//
//  ExploreMapView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct ExploreMapView: View {

    @StateObject var viewModel: ExploreMapViewModel

    var body: some View {
        Text("Explore map view")
    }
}

struct ExploreMapView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreMapView(
            viewModel: .init(
                flowCoordinator: DummyFlowCoordinator.shared,
                appDependencies: DummyAppDependencies.shared
            )
        )
    }
}
