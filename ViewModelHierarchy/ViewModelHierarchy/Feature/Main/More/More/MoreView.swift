//
//  MoreView.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 23/07/2024.
//

import SwiftUI

struct MoreView: View {
    let viewModel: ViewModel

    var body: some View {
        List {
            Section("Info") {
                Text("Some info")
            }

            Section("Details") {
                Button("Some details") {
                    viewModel.didTapDetails()
                }
            }

            Section("Misc") {
                Button("Re-enroll") {
                    viewModel.didTapReEnroll()
                }
            }
        }
        .navigationTitle("More")
    }
}

// MARK: MoreView+ViewModel

extension MoreView {
    @Observable
    final class ViewModel: ActionableViewModel<ViewModel.Action>, Hashable, Identifiable {
        enum Action {
            case didTapDetails
            case didTapReEnroll
        }

        // MARK: View Events

        func didTapDetails() {
            onAction?(.didTapDetails)
        }

        func didTapReEnroll() {
            onAction?(.didTapReEnroll)
        }
    }
}
