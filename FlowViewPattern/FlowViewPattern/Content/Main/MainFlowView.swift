//
//  MainFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct MainFlowView: View {

    @StateObject var flowViewModel: MainFlowViewModel

    @State private var bookingPresented: Bool = false

    var body: some View {
        TabView {
            flowViewModel.makeExploreFlowView()
                .tabItem {
                    Label("Explore", systemImage: "map")
                }
            flowViewModel.makeActivityFlowView()
                .tabItem {
                    Label("Activity", systemImage: "star")
                }
            flowViewModel.makeProfileFlowView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .sheet(isPresented: $bookingPresented) {
            flowViewModel.makeBookingFlowView()
        }
    }
}

struct MainFlowView_Previews: PreviewProvider {
    static var previews: some View {
        MainFlowView(
            flowViewModel: .init(
                flowCoordinator: MockFlowCoordinator.shared,
                appDependencies: MockAppDependencies.shared
            )
        )
    }
}
