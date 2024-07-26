//
//  OnboardingCoordinatorView.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 23/07/2024.
//

import SwiftUI

struct OnboardingCoordinatorView: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            TabView {
                VStack {
                    Text("Page One")
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.tertiary)
                .clipShape(.rect(cornerRadius: 8))
                .padding()

                VStack {
                    Text("Page Two")
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.tertiary)
                .clipShape(.rect(cornerRadius: 8))
                .padding()

                VStack {
                    Text("Page Three")
                        .padding()

                    Button("Done") {
                        viewModel.didTapDone()
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.tertiary)
                .clipShape(.rect(cornerRadius: 8))
                .padding()
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .navigationTitle("Onboarding")
        }
    }
}

// MARK: OnboardingCoordinatorView+ViewModel

extension OnboardingCoordinatorView {
    @Observable
    final class ViewModel: ActionableViewModel<ViewModel.Action>, Hashable {
        enum Action {
            case didCompleteOnboarding
        }

        // MARK: View Events

        func didTapDone() {
            onAction?(.didCompleteOnboarding)
        }
    }
}
