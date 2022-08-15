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
            flowViewFactory.makeExploreFlowView(
                with: flowViewModel,
                at: flowViewModel.currentPage
            )
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
        .sheet(isPresented: $flowViewModel.bookingIsPresented) {
            flowViewFactory.makeBookingFlowView()
        }
        .sheet(isPresented: $flowViewModel.greetingIsPresented) {
            flowViewFactory.makeWelcomeBackView(
                with: flowViewModel
            )
        }
        .onOpenURL { url in
            guard
                let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
                let appPage: AppPage = .from(urlComponents),
                let page = appPage.asMainPage()
            else {
                return
            }

            flowViewModel.go(to: page)
        }
    }
}

extension AppPage {
    func asMainPage() -> AppPage.Main? {
        switch self {
        case let .main(page):
            return page
        default:
            return nil
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
}

struct MainFlowView_Previews: PreviewProvider {
    static var previews: some View {
        MainFlowView(
            flowViewModel: .init(
                flowCoordinator: PreviewFlowCoordinator.shared,
                appDependencies: PreviewAppDependencies.shared,
                currentPage: .main(page: .explore(page: .store(page: .map())))
            ),
            flowViewFactory: PreviewFlowViewFactory.shared
        )
    }
}
