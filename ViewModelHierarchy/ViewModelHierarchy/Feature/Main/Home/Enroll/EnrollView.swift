//
//  EnrollView.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 23/07/2024.
//

import SwiftUI

struct EnrollView: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        ScrollView {
            VStack {
                Text("Enroll to get started")
                    .padding()

                Button("Enroll Now!") {
                    viewModel.didTapEnroll()
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Settings", systemImage: "gear") {
                    viewModel.didTapSettings()
                }

                Button("About", systemImage: "info") {
                    viewModel.didTapAbout()
                }
            }
        }
        .navigationTitle("Home")
    }
}

// MARK: EnrollView+ViewModel

extension EnrollView {
    @Observable
    final class ViewModel: ActionableViewModel<ViewModel.Action>, Hashable, Identifiable {
        enum Action {
            case didTapEnroll
            case didTapSettings
            case didTapAbout
        }

        // MARK: View Events

        func didTapEnroll() {
            onAction?(.didTapEnroll)
        }

        func didTapSettings() {
            onAction?(.didTapSettings)
        }

        func didTapAbout() {
            onAction?(.didTapAbout)
        }
    }
}
