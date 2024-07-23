//
//  HomeCoordinatorView.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 23/07/2024.
//

import SwiftUI

struct HomeCoordinatorView: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        NavigationStack(path: $viewModel.pageStack) {
            view(for: viewModel.activeRootPage)
                .transition(CardFlipTransition())
                .navigationDestination(for: StackPage.self) { page in
                    view(for: page)
                }
                .animation(.default, value: viewModel.activeRootPage)
                .toolbar(viewModel.tabBarVisibility, for: .tabBar)
                .animation(.default, value: viewModel.tabBarVisibility)
        }
    }

    @ViewBuilder
    private func view(for page: StackPage) -> some View {
        switch page {
            case .home(let homeViewModel):
                HomeView(viewModel: homeViewModel)
            case .enroll(let enrollViewModel):
                EnrollView(viewModel: enrollViewModel)
            case .profile:
                ProfileView()
        }
    }
}

// MARK: HomeCoordinatorView+StackPage

extension HomeCoordinatorView {
    /// An enumeration representing possible Pages hosted by the ``HomeCoordinatorView``.
    enum StackPage: Hashable, Identifiable {
        case home(HomeView.ViewModel)
        case enroll(EnrollView.ViewModel)
        case profile
    }
}

// MARK: HomeCoordinatorView+ViewModel

extension HomeCoordinatorView {
    @Observable
    final class ViewModel: ActionableViewModel<ViewModel.Action> {
        enum Action {
            case didTapEnroll
            case didTapSettings
            case didTapAbout
        }

        var tabBarVisibility: Visibility = .visible

        var activeRootPage: StackPage

        var pageStack: [StackPage] = [] {
            didSet {
                switch pageStack.last {
                    case .profile:
                        tabBarVisibility = .hidden
                    default:
                        tabBarVisibility = .visible
                }
            }
        }

        @ObservationIgnored
        var hasEnrolled: Bool {
            didSet {
                if hasEnrolled {
                    let homeViewModel = HomeView.ViewModel(onAction: nil)
                    listen(to: homeViewModel)
                    activeRootPage = .home(homeViewModel)
                } else {
                    let enrollViewModel = EnrollView.ViewModel(onAction: nil)
                    listen(to: enrollViewModel)
                    activeRootPage = .enroll(enrollViewModel)
                }
            }
        }

        init(hasEnrolled: Bool, onAction: ((Action) -> Void)?, path: AppPath.RootPath.MainPath.HomePath?) {
            self.hasEnrolled = hasEnrolled

            guard hasEnrolled else {
                let enrollViewModel = EnrollView.ViewModel(onAction: nil)
                activeRootPage = .enroll(enrollViewModel)
                super.init(onAction: onAction)
                listen(to: enrollViewModel)
                return
            }

            switch path {
                case .profile:
                    let enrollViewModel = EnrollView.ViewModel(onAction: nil)
                    activeRootPage = .enroll(enrollViewModel)
                    super.init(onAction: onAction)
                    listen(to: enrollViewModel)
                default:
                    let homeViewModel = HomeView.ViewModel(onAction: nil)
                    activeRootPage = .home(homeViewModel)
                    super.init(onAction: onAction)
                    listen(to: homeViewModel)
            }
        }

        // MARK: ViewModel Factory Methods

        private func listen(to viewModel: HomeView.ViewModel) {
            viewModel.onAction = { [weak self] action in
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

        private func listen(to viewModel: EnrollView.ViewModel) {
            viewModel.onAction = { [weak self] action in
                switch action {
                    case .didTapEnroll:
                        self?.onAction?(.didTapEnroll)
                    case .didTapSettings:
                        self?.onAction?(.didTapSettings)
                    case .didTapAbout:
                        self?.onAction?(.didTapAbout)
                }
            }
        }
    }
}

// MARK: Deep Linking

extension HomeCoordinatorView.ViewModel {
    func handle(_ path: AppPath.RootPath.MainPath.HomePath) {
        switch path {
            case .home:
                let homeViewModel = HomeView.ViewModel(onAction: nil)
                activeRootPage = .home(homeViewModel)
                listen(to: homeViewModel)
            case .profile:
                let enrollViewModel = EnrollView.ViewModel(onAction: nil)
                activeRootPage = .enroll(enrollViewModel)
                listen(to: enrollViewModel)
        }
    }
}
