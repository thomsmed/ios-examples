//
//  MainFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct MainFlowView: View {

    @StateObject var flowViewModel: MainFlowViewModel

    var body: some View {
        TabView(selection: $flowViewModel.activeTab) {
            flowViewModel.makeExploreFlowView()
                .tag(MainFlowViewModel.Tab.explore)
                .tabItem {
                    Label(
                        MainFlowViewModel.Tab.explore.title,
                        systemImage: MainFlowViewModel.Tab.explore.systemImageName
                    )
                }
            flowViewModel.makeActivityFlowView()
                .tag(MainFlowViewModel.Tab.activity)
                .tabItem {
                    Label(
                        MainFlowViewModel.Tab.activity.title,
                        systemImage: MainFlowViewModel.Tab.activity.systemImageName
                    )
                }
            flowViewModel.makeProfileFlowView()
                .tag(MainFlowViewModel.Tab.profile)
                .tabItem {
                    Label(
                        MainFlowViewModel.Tab.profile.title,
                        systemImage: MainFlowViewModel.Tab.profile.systemImageName
                    )
                }
        }
        .sheet(isPresented: $flowViewModel.sheetIsPresented) {
            switch flowViewModel.presentedSheet {
            case .none:
                EmptyView()
            case .booking:
                flowViewModel.makeBookingFlowView()
            case .greeting:
                flowViewModel.makeWelcomeBackView()
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
