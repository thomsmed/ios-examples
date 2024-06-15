//
//  MoreCoordinatorView.swift
//  ActionableViewModel
//
//  Created by Thomas Asheim Smedmann on 15/06/2024.
//

import SwiftUI

struct MoreCoordinatorView: View {
    @State var viewModel: ViewModel

    var body: some View {
        NavigationStack(path: $viewModel.pageStack) {
            MoreView(
                viewModel: viewModel.makeMoreViewModel()
            )
            .navigationDestination(for: SubPage.self) { subPage in
                switch subPage {
                    case .details:
                        DetailsView()
                }
            }
        }
    }
}

// MARK: MoreCoordinatorView+SubPage

extension MoreCoordinatorView {
    /// An enumeration representing possible SubPages hosted by the ``MoreCoordinatorView``.
    enum SubPage: Identifiable {
        case details

        var id: Self { self }
    }
}

// MARK: MoreCoordinatorView+ViewModel

extension MoreCoordinatorView {
    @Observable
    final class ViewModel: ActionableViewModel<ViewModel.Action> {
        enum Action {
            case didTapReEnroll
        }

        var pageStack: [SubPage] = []

        // MARK: ViewModel Factory Methods

        func makeMoreViewModel() -> MoreView.ViewModel {
            MoreView.ViewModel { [weak self] action in
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
