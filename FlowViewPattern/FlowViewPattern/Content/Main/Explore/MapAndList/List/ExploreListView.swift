//
//  ExploreListView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct ExploreListView: View {

    @StateObject var viewModel: ExploreListViewModel

    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        VStack {
            Button("Map") {

            }
            .padding(.bottom, 16)
            Text("Explore list")
                .padding(16)
            Button("Booking") {
                //viewModel.continueToBooking()
            }.padding(.top, 16)
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

struct ExploreListView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreListView(
            viewModel: .init(
                flowCoordinator: MockFlowCoordinator.shared,
                appDependencies: MockAppDependencies.shared
            )
        )
    }
}
