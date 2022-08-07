//
//  MainFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct MainFlowView: View {

    @StateObject var flowViewModel: MainFlowViewModel

    @State private var sheetIsPresented: Bool = false

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
        .onChange(of: flowViewModel.presentedSheet) { presentedSheet in
            switch presentedSheet {
            case .none:
                sheetIsPresented = false
            default:
                sheetIsPresented = true
            }
        }
        .sheet(
            isPresented: $sheetIsPresented,
            onDismiss: {
                flowViewModel.presentedSheetDismissed()
            }
        ) {
            switch flowViewModel.presentedSheet {
            case .none, .booking:
                flowViewModel.makeBookingFlowView()
            }
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
