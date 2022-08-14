//
//  ExploreMapView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct ExploreMapView: View {

    @State var viewModel: ExploreMapViewModel

    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        VStack {
            Button("List") {
                viewModel.goToList()
            }
            .padding(.bottom, 16)
            Text("Explore map")
                .padding(16)
            Button("Booking") {
                viewModel.continueToBooking()
            }.padding(.top, 16)
        }
        .task {
            // Run asynchronously
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
                flowCoordinator: PreviewFlowCoordinator.shared
            )
        )
    }
}
