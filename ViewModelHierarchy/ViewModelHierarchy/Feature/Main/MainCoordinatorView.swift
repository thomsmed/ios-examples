//
//  MainCoordinatorView.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 23/07/2024.
//

import SwiftUI

struct MainCoordinatorView: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        TabView(selection: $viewModel.activeTab) {
            // iOS 18+
            Tab(TabPage.home.title, systemImage: TabPage.home.systemImage, value: TabPage.home) {
                HomeCoordinatorView(viewModel: viewModel.homeCoordinatorViewModel)
            }

            Tab(TabPage.more.title, systemImage: TabPage.more.systemImage, value: TabPage.more) {
                MoreCoordinatorView(viewModel: viewModel.moreCoordinatorViewModel)
            }

            // iOS 13+
//            HomeCoordinatorView(viewModel: viewModel.homeCoordinatorViewModel)
//                .tabItem {
//                    Label(TabPage.home.title, systemImage: TabPage.home.systemImage)
//                }
//                .tag(TabPage.home)
//
//            MoreCoordinatorView(viewModel: viewModel.moreCoordinatorViewModel)
//                .tabItem {
//                    Label(TabPage.more.title, systemImage: TabPage.more.systemImage)
//                }
//                .tag(TabPage.more)
        }
        .fullScreenCover(item: $viewModel.presentedPage) {
            viewModel.didDismissPage()
        } content: { page in
            view(for: page)
        }
        .sheet(item: $viewModel.presentedSheet) {
            viewModel.didDismissSheet()
        } content: { sheet in
            view(for: sheet)
        }
    }

    @ViewBuilder
    private func view(for page: FullScreenPage) -> some View {
        switch page {
            case .enrollment(let enrollmentViewModel):
                EnrollmentCoordinatorView(viewModel: enrollmentViewModel)
        }
    }

    @ViewBuilder
    private func view(for sheet: SheetPage) -> some View {
        switch sheet {
            case .settings:
                SettingsCoordinatorView()
        }
    }
}

// MARK: MainCoordinatorView+TabPage

extension MainCoordinatorView {
    /// An enumeration representing possible navigation flows that can be hosted as Tabs by the ``MainCoordinatorView``.
    enum TabPage: Hashable, Identifiable {
        case home
        case more

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

// MARK: MainCoordinatorView+FullScreenPage

extension MainCoordinatorView {
    /// An enumeration representing possible navigation flows that can be presented full-screen as Pages by the ``MainCoordinatorView``.
    enum FullScreenPage: Hashable, Identifiable {
        case enrollment(EnrollmentCoordinatorView.ViewModel)
    }
}

// MARK: MainCoordinatorView+SheetPage

extension MainCoordinatorView {
    /// An enumeration representing possible navigation flows that can be presented as Sheets by the ``MainCoordinatorView``.
    enum SheetPage: Hashable, Identifiable {
        case settings
    }
}

// MARK: MainCoordinatorView+ViewModel

extension MainCoordinatorView {
    @Observable
    final class ViewModel: ActionableViewModel<ViewModel.Action>, Hashable {
        enum Action {
            case didTapAbout
        }

        var activeTab: TabPage

        var presentedSheet: SheetPage? = nil
        private var lastPresentedSheet: SheetPage? = nil

        var presentedPage: FullScreenPage? = nil
        private var lastPresentedPage: FullScreenPage? = nil

        private(set) var homeCoordinatorViewModel: HomeCoordinatorView.ViewModel
        private(set) var moreCoordinatorViewModel: MoreCoordinatorView.ViewModel

        private var hasEnrolled: Bool

        init(onAction: ((Action) -> Void)?, path: AppPath.RootPath.MainPath?) {
            let hasEnrolled = false

            homeCoordinatorViewModel = HomeCoordinatorView.ViewModel(hasEnrolled: hasEnrolled, onAction: nil, path: path?.homePath)
            moreCoordinatorViewModel = MoreCoordinatorView.ViewModel(onAction: nil, path: path?.morePath)

            switch path {
                case .more:
                    activeTab = .more
                case .settings:
                    activeTab = .home
                    presentedSheet = .settings
                    lastPresentedSheet = .settings
                default:
                    activeTab = .home
            }

            self.hasEnrolled = hasEnrolled

            super.init(onAction: onAction)

            listen(to: homeCoordinatorViewModel)
            listen(to: moreCoordinatorViewModel)
        }

        private func present(_ page: FullScreenPage) {
            presentedPage = page
            lastPresentedPage = page
        }

        private func present(_ sheet: SheetPage) {
            presentedSheet = sheet
            lastPresentedSheet = sheet
        }

        // MARK: Page and Sheed dismissal

        func didDismissPage() {
            switch lastPresentedPage {
                case .enrollment:
                    homeCoordinatorViewModel.hasEnrolled = true
                case nil:
                    break
            }
        }

        func didDismissSheet() {
            switch lastPresentedSheet {
                case .settings:
                    break
                case nil:
                    break
            }
        }

        // MARK: ViewModel Factory Methods

        private func listen(to viewModel: HomeCoordinatorView.ViewModel) {
            viewModel.onAction = { [weak self] action in
                guard let self else { return }
                switch action {
                    case .didTapEnroll:
                        let enrollmentCoordinatorViewModel = EnrollmentCoordinatorView.ViewModel(onAction: nil)
                        self.listen(to: enrollmentCoordinatorViewModel)
                        self.present(.enrollment(enrollmentCoordinatorViewModel))
                    case .didTapSettings:
                        self.present(.settings)
                    case .didTapAbout:
                        self.onAction?(.didTapAbout)
                }
            }
        }

        private func listen(to viewModel: MoreCoordinatorView.ViewModel) {
            viewModel.onAction = { [weak self] action in
                guard let self else { return }
                switch action {
                    case .didTapReEnroll:
                        let enrollmentCoordinatorViewModel = EnrollmentCoordinatorView.ViewModel(onAction: nil)
                        self.listen(to: enrollmentCoordinatorViewModel)
                        self.present(.enrollment(enrollmentCoordinatorViewModel))
                }
            }
        }

        private func listen(to viewModel: EnrollmentCoordinatorView.ViewModel) {
            viewModel.onAction = { [weak self] action in
                guard let self else { return }
                switch action {
                    case .didCompleteEnrollment:
                        self.hasEnrolled = true
                        self.activeTab = .home
                        self.presentedPage = nil
                }
            }
        }
    }
}

// MARK: Deep Linking

extension MainCoordinatorView.ViewModel {
    func handle(_ path: AppPath.RootPath.MainPath) {
        switch path {
            case .home(let path):
                activeTab = .home
                presentedPage = nil
                homeCoordinatorViewModel.handle(path)
            case .more(let path):
                activeTab = .more
                presentedPage = nil
                moreCoordinatorViewModel.handle(path)
            case .settings:
                present(.settings)
        }
    }
}
