//
//  HomeCoordinatorView.swift
//  ActionableViewModel
//
//  Created by Thomas Asheim Smedmann on 15/06/2024.
//

import SwiftUI

struct HomeCoordinatorView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        NavigationStack(path: $viewModel.pageStack) {
            HomeView(
                viewModel: viewModel.makeHomeViewModel()
            )
            .navigationDestination(for: SubPage.self) { subPage in
                switch subPage {
                    case .profile:
                        ProfileView()
                }
            }
            .toolbar(viewModel.tabBarVisibility, for: .tabBar)
            .animation(.default, value: viewModel.tabBarVisibility)
        }
    }
}

// MARK: HomeCoordinatorView+SubPage

extension HomeCoordinatorView {
    /// An enumeration representing possible SubPages hosted by the ``HomeCoordinatorView``.
    enum SubPage: Identifiable {
        case profile

        var id: Self { self }
    }
}

// MARK: HomeCoordinatorView+ViewModel

extension HomeCoordinatorView {
    final class ViewModel: ActionableViewModel<ViewModel.Action> {
        enum Action {
            case didTapSettings
            case didTapAbout
        }

        @Published var tabBarVisibility: Visibility = .visible
        @Published var pageStack: [SubPage] = [] {
            didSet {
                switch pageStack.last {
                    case .none:
                        tabBarVisibility = .visible
                    case .profile:
                        tabBarVisibility = .hidden
                }
            }
        }

        // MARK: ViewModel Factory Methods

        func makeHomeViewModel() -> HomeView.ViewModel {
            HomeView.ViewModel { [weak self] action in
                switch action {
                    case .didTapProfile:
                        self?.pageStack.append(.profile)
                    case .didTapSettings:
                        self?.onAction?(.didTapSettings)
                    case .didTapAbout:
                        self?.onAction?(.didTapAbout)
                }
            }
        }
    }
}
