//
//  MainFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct MainFlowView: View {

    @StateObject var flowViewModel: MainFlowViewModel
    let flowViewFactory: MainFlowViewFactory

    var body: some View {
        TabView(selection: $flowViewModel.selectedTab) {
            flowViewFactory.makeExploreFlowView(with: flowViewModel)
                .tag(Tab.explore)
                .tabItem {
                    Label(
                        Tab.explore.title,
                        systemImage: Tab.explore.systemImageName
                    )
                }
            flowViewFactory.makeActivityFlowView()
                .tag(Tab.activity)
                .tabItem {
                    Label(
                        Tab.activity.title,
                        systemImage: Tab.activity.systemImageName
                    )
                }
            flowViewFactory.makeProfileFlowView()
                .tag(Tab.profile)
                .tabItem {
                    Label(
                        Tab.profile.title,
                        systemImage: Tab.profile.systemImageName
                    )
                }
        }
        .sheet(isPresented: $flowViewModel.sheetIsPresented) {
            switch flowViewModel.presentedSheet {
            case .none:
                EmptyView()
            case .booking:
                flowViewFactory.makeBookingFlowView()
            case .greeting:
                flowViewFactory.makeWelcomeBackView(with: flowViewModel)
            }
        }
    }
}

extension MainFlowView {

    enum Tab {
        case explore
        case activity
        case profile

        var title: String {
            switch self {
            case .explore:
                return "Explore"
            case .activity:
                return "Activity"
            case .profile:
                return "Profile"
            }
        }

        var systemImageName: String {
            switch self {
            case .explore:
                return "map"
            case .activity:
                return "star"
            case .profile:
                return "person"
            }
        }
    }

    enum PresentedSheet {
        case none
        case booking
        case greeting
    }
}

struct MainFlowView_Previews: PreviewProvider {
    static var previews: some View {
        MainFlowView(
            flowViewModel: .init(
                flowCoordinator: PreviewFlowCoordinator.shared,
                appDependencies: PreviewAppDependencies.shared
            ),
            flowViewFactory: PreviewFlowViewFactory.shared
        )
    }
}
