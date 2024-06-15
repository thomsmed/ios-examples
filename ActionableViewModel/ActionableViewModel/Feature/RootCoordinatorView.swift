//
//  RootCoordinatorView.swift
//  ActionableViewModel
//
//  Created by Thomas Asheim Smedmann on 16/06/2024.
//

import SwiftUI

struct RootCoordinatorView: View {
    @State var viewModel: ViewModel

    var body: some View {
        Group {
            switch viewModel.selectedFlow {
                case .onboarding:
                    OnboardingCoordinatorView(
                        viewModel: viewModel.makeOnboardingCoordinatorViewModel()
                    )
                    .transition(.push(from: viewModel.transitionEdge))

                case .main:
                    MainCoordinatorView(
                        viewModel: viewModel.makeMainCoordinatorViewModel()
                    )
                    .transition(.push(from: viewModel.transitionEdge))

                case .about:
                    AboutCoordinatorView(
                        viewModel: viewModel.makeAboutCoordinatorViewModel()
                    )
                    .transition(.push(from: viewModel.transitionEdge))
            }
        }
        .animation(.default, value: viewModel.selectedFlow)
    }
}

// MARK: RootCoordinatorView+Flow

extension RootCoordinatorView {
    /// An enumeration representing possible root navigation Flows that can moved between by the ``RootCoordinatorView``.
    enum Flow: Identifiable {
        case onboarding
        case main
        case about

        var id: Self { self }
    }
}

// MARK: RootCoordinatorView+ViewModel

extension RootCoordinatorView {
    @Observable
    final class ViewModel: ActionableViewModel<ViewModel.Action> {
        enum Action {}

        var transitionEdge: Edge = .trailing
        var selectedFlow: Flow = .onboarding

        // MARK: ViewModel Factory Methods

        func makeOnboardingCoordinatorViewModel() -> OnboardingCoordinatorView.ViewModel {
            OnboardingCoordinatorView.ViewModel { [weak self] action in
                switch action {
                    case .didCompleteOnboarding:
                        self?.transitionEdge = .trailing

                        Task {
                            // Let SwiftUI evaluate the changes to transitionEdge before we actually select a new flow.
                            await MainActor.run {
                                self?.selectedFlow = .main
                            }
                        }
                }
            }
        }

        func makeMainCoordinatorViewModel() -> MainCoordinatorView.ViewModel {
            MainCoordinatorView.ViewModel() { [weak self] action in
                switch action {
                    case .didTapAbout:
                        self?.transitionEdge = .trailing

                        Task {
                            // Let SwiftUI evaluate the changes to transitionEdge before we actually select a new flow.
                            await MainActor.run {
                                self?.selectedFlow = .about
                            }
                        }
                }
            }
        }

        func makeAboutCoordinatorViewModel() -> AboutCoordinatorView.ViewModel {
            AboutCoordinatorView.ViewModel { [weak self] action in
                switch action {
                    case .didTapClose:
                        self?.transitionEdge = .leading

                        Task {
                            // Let SwiftUI evaluate the changes to transitionEdge before we actually select a new flow.
                            await MainActor.run {
                                self?.selectedFlow = .main
                            }
                        }
                }
            }
        }
    }
}
