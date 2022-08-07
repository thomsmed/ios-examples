//
//  ExploreMapView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct ExploreMapView: View {

    @StateObject var viewModel: ExploreMapViewModel

    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        ZStack {
            Text("Explore map view")
        }
        .onAppear() {
            // Refresh view etc
        }
        .onChange(of: scenePhase) { newScenePhase in
            guard newScenePhase == .active else {
                return
            }

            // Refresh view etc
        }
    }
}

struct ExploreMapView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreMapView(
            viewModel: .init(
                flowCoordinator: MockFlowCoordinator.shared,
                appDependencies: MockAppDependencies.shared
            )
        )
    }
}
