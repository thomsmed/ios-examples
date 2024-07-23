//
//  RootCoordinatorView.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 23/07/2024.
//

import SwiftUI

struct RootCoordinatorView: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        Group {
            switch viewModel.activeRootFlow {
                case .onboarding(let onboardingViewModel):
                    OnboardingCoordinatorView(viewModel: onboardingViewModel)
                        .transition(.push(from: viewModel.transitionEdge))

                case .main(let mainViewModel):
                    MainCoordinatorView(viewModel: mainViewModel)
                        .transition(.push(from: viewModel.transitionEdge))

                case .about(let aboutViewModel):
                    AboutCoordinatorView(viewModel: aboutViewModel)
                        .transition(.push(from: viewModel.transitionEdge))
            }
        }
        .animation(.default, value: viewModel.activeRootFlow)
    }
}

// MARK: RootCoordinatorView+RootFlow

extension RootCoordinatorView {
    /// An enumeration representing possible root navigation Flows that can be moved between by the ``RootCoordinatorView``.
    enum RootFlow: Hashable, Identifiable {
        case onboarding(OnboardingCoordinatorView.ViewModel)
        case main(MainCoordinatorView.ViewModel)
        case about(AboutCoordinatorView.ViewModel)
    }
}

// MARK: RootCoordinatorView+ViewModel

extension RootCoordinatorView {
    @Observable
    final class ViewModel: ActionableViewModel<ViewModel.Action> {
        enum Action {}

        private(set) var transitionEdge: Edge
        private(set) var activeRootFlow: RootFlow

        init() {
            self.transitionEdge = .trailing

            if false { // Simulate that onboarding is not initially completed
                let mainCoordinatorViewModel = MainCoordinatorView.ViewModel(onAction: nil, path: nil)
                self.activeRootFlow = .main(mainCoordinatorViewModel)
                super.init(onAction: nil)
                listen(to: mainCoordinatorViewModel)
            } else {
                let onboardingCoordinatorViewModel = OnboardingCoordinatorView.ViewModel(onAction: nil)
                self.activeRootFlow = .onboarding(onboardingCoordinatorViewModel)
                super.init(onAction: nil)
                listen(to: onboardingCoordinatorViewModel)
            }
        }

        // MARK: ViewModel Factory Methods

        private func listen(to viewModel: OnboardingCoordinatorView.ViewModel) {
            viewModel.onAction = { [weak self] action in
                switch action {
                    case .didCompleteOnboarding:
                        self?.transitionToMainFlow(fromEdge: .trailing, withPath: nil)
                }
            }
        }

        private func listen(to viewModel: MainCoordinatorView.ViewModel) {
            viewModel.onAction = { [weak self] action in
                switch action {
                    case .didTapAbout:
                        self?.transitionToAboutFlow(fromEdge: .trailing)
                }
            }
        }

        private func listen(to viewModel: AboutCoordinatorView.ViewModel) {
            viewModel.onAction = { [weak self] action in
                switch action {
                    case .didTapClose:
                        self?.transitionToMainFlow(fromEdge: .leading, withPath: nil)
                }
            }
        }

        private func transitionToMainFlow(fromEdge edge: Edge, withPath path: AppPath.RootPath.MainPath?) {
            transitionEdge = edge

            Task {
                // Let SwiftUI evaluate the changes to transitionEdge before we actually select a new flow.
                await MainActor.run {
                    let mainCoordinatorViewModel = MainCoordinatorView.ViewModel(onAction: nil, path: path)
                    self.listen(to: mainCoordinatorViewModel)
                    self.activeRootFlow = .main(mainCoordinatorViewModel)
                }
            }
        }

        private func transitionToAboutFlow(fromEdge edge: Edge) {
            transitionEdge = edge

            Task {
                // Let SwiftUI evaluate the changes to transitionEdge before we actually select a new flow.
                await MainActor.run {
                    let aboutCoordinatorViewModel = AboutCoordinatorView.ViewModel(onAction: nil)
                    self.listen(to: aboutCoordinatorViewModel)
                    self.activeRootFlow = .about(aboutCoordinatorViewModel)
                }
            }
        }
    }
}

// MARK: Deep Linking

extension RootCoordinatorView.ViewModel {
    func handle(_ path: AppPath) {
        guard case .root(let path) = path else {
            return
        }

        switch path {
            case .about:
                if case .about = activeRootFlow {
                    return
                } else {
                    transitionToAboutFlow(fromEdge: .trailing)
                }

            case .main(let path):
                if case .main(let mainCoordinatorViewModel) = activeRootFlow {
                    mainCoordinatorViewModel.handle(path)
                } else {
                    transitionToMainFlow(fromEdge: .leading, withPath: path)
                }
        }
    }
}
