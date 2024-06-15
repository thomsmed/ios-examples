//
//  OnboardingCoordinatorView.swift
//  ActionableViewModel
//
//  Created by Thomas Asheim Smedmann on 16/06/2024.
//

import SwiftUI

struct OnboardingCoordinatorView: View {
    @State var viewModel: ViewModel

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
    struct ViewModel: Actionable {
        enum Action {
            case didCompleteOnboarding
        }

        var onAction: ((Action) -> Void)?

        // MARK: View Events

        func didTapDone() {
            onAction?(.didCompleteOnboarding)
        }
    }
}
