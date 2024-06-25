//
//  MainCoordinatorView.swift
//  ActionableViewModel
//
//  Created by Thomas Asheim Smedmann on 15/06/2024.
//

import SwiftUI

struct MainCoordinatorView: View {
    @State var viewModel: ViewModel

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            HomeCoordinatorView(
                viewModel: viewModel.makeHomeCoordinatorViewModel()
            )
            .tabItem {
                Label(Tab.home.title, systemImage: Tab.home.systemImage)
            }

            MoreCoordinatorView(
                viewModel: viewModel.makeMoreCoordinatorViewModel()
            )
            .tabItem {
                Label(Tab.more.title, systemImage: Tab.more.systemImage)
            }
        }
        .sheet(item: $viewModel.presentedSheet) { sheet in
            switch sheet {
                case .settings:
                    SettingsCoordinatorView()
            }
        }
        .fullScreenCover(item: $viewModel.presentedPage) { page in
            switch page {
                case .enrollment:
                    EnrollmentCoordinatorView(
                        viewModel: viewModel.makeEnrollmentCoordinatorViewModel()
                    )
            }
        }
    }
}

// MARK: MainCoordinatorView+Tab

extension MainCoordinatorView {
    /// An enumeration representing possible navigation flows that can be hosted as Tabs by the ``MainCoordinatorView``.
    enum Tab: Identifiable {
        case home
        case more

        var id: Self { self }

        var title: LocalizedStringKey {
            switch self {
                case .home: "Home"
                case .more: "More"
            }
        }

        var systemImage: String {
            switch self {
                case .home: "house"
                case .more: "square.grid.2x2"
            }
        }
    }
}

// MARK: MainCoordinatorView+Sheet

extension MainCoordinatorView {
    /// An enumeration representing possible navigation flows that can be presented as Sheets by the ``MainCoordinatorView``.
    enum Sheet: Identifiable {
        case settings

        var id: Self { self }
    }
}

// MARK: MainCoordinatorView+Page

extension MainCoordinatorView {
    /// An enumeration representing possible navigation flows that can be presented full-screen as Pages by the ``MainCoordinatorView``.
    enum Page: Identifiable {
        case enrollment

        var id: Self { self }
    }
}

// MARK: MainCoordinatorView+ViewModel

extension MainCoordinatorView {
    @Observable
    final class ViewModel: ActionableViewModel<ViewModel.Action> {
        enum Action {
            case didTapAbout
        }

        var selectedTab: Tab = .home
        var presentedSheet: Sheet? = nil
        var presentedPage: Page? = nil

        // MARK: ViewModel Factory Methods

        func makeHomeCoordinatorViewModel() -> HomeCoordinatorView.ViewModel {
            HomeCoordinatorView.ViewModel { [weak self] action in
                switch action {
                    case .didTapSettings:
                        self?.presentedSheet = .settings
                    case .didTapAbout:
                        self?.onAction?(.didTapAbout)
                }
            }
        }

        func makeMoreCoordinatorViewModel() -> MoreCoordinatorView.ViewModel {
            MoreCoordinatorView.ViewModel { [weak self] action in
                switch action {
                    case .didTapReEnroll:
                        self?.presentedPage = .enrollment
                }
            }
        }

        func makeEnrollmentCoordinatorViewModel() -> EnrollmentCoordinatorView.ViewModel {
            EnrollmentCoordinatorView.ViewModel { [weak self] action in
                switch action {
                    case .didCompleteEnrollment:
                        self?.presentedPage = nil
                }
            }
        }
    }
}
