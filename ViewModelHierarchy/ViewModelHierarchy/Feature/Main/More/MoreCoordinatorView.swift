//
//  MoreCoordinatorView.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 23/07/2024.
//

import SwiftUI

struct MoreCoordinatorView: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        NavigationStack(path: $viewModel.pageStack) {
            view(for: viewModel.activeRootPage)
                .navigationDestination(for: StackPage.self) { page in
                    view(for: page)
                }
        }
    }

    @ViewBuilder
    private func view(for page: StackPage) -> some View {
        switch page {
            case .more(let moreViewModel):
                MoreView(viewModel: moreViewModel)
            case .details:
                DetailsView()
        }
    }
}

// MARK: MoreCoordinatorView+StackPage

extension MoreCoordinatorView {
    /// An enumeration representing possible Pages hosted by the ``MoreCoordinatorView``.
    enum StackPage: Hashable, Identifiable {
        case more(MoreView.ViewModel)
        case details
    }
}

// MARK: MoreCoordinatorView+ViewModel

extension MoreCoordinatorView {
    @Observable
    final class ViewModel: ActionableViewModel<ViewModel.Action> {
        enum Action {
            case didTapReEnroll
        }

        var activeRootPage: StackPage
        var pageStack: [StackPage] = []

        init(onAction: ((Action) -> Void)?, path: AppPath.RootPath.MainPath.MorePath?) {
            switch path {
                case .details:
                    pageStack = [.details]
                    let moreViewModel = MoreView.ViewModel(onAction: nil)
                    activeRootPage = .more(moreViewModel)
                    super.init(onAction: onAction)
                    listen(to: moreViewModel)
                default:
                    let moreViewModel = MoreView.ViewModel(onAction: nil)
                    activeRootPage = .more(moreViewModel)
                    super.init(onAction: onAction)
                    listen(to: moreViewModel)
            }
        }

        // MARK: ViewModel Factory Methods

        private func listen(to viewModel: MoreView.ViewModel) {
            viewModel.onAction = { [weak self] action in
                switch action {
                    case .didTapDetails:
                        self?.pageStack.append(.details)
                    case .didTapReEnroll:
                        self?.onAction?(.didTapReEnroll)
                }
            }
        }
    }
}

// MARK: Deep Linking

extension MoreCoordinatorView.ViewModel {
    func handle(_ path: AppPath.RootPath.MainPath.MorePath) {
        switch path {
            case .more:
                let moreViewModel = MoreView.ViewModel(onAction: nil)
                activeRootPage = .more(moreViewModel)
                listen(to: moreViewModel)
            case .details:
                pageStack = [.details]
        }
    }
}
