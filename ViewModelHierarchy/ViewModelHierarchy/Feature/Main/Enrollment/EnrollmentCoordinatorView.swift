//
//  EnrollmentCoordinatorView.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 23/07/2024.
//

import SwiftUI

struct EnrollmentCoordinatorView: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Text("Enroll here!")
                    .padding()

                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Button("Enroll") {
                        viewModel.didTapDone()
                    }
                    .padding()
                }
            }
            .navigationTitle("Enrollment")
        }
    }
}

// MARK: EnrollmentCoordinatorView+ViewModel

extension EnrollmentCoordinatorView {
    @Observable
    final class ViewModel: ActionableViewModel<ViewModel.Action>, Hashable, Identifiable {
        enum Action {
            case didCompleteEnrollment
        }

        var isLoading: Bool = false

        // MARK: View Events

        func didTapDone() {
            isLoading = true

            Task {
                try await Task.sleep(for: .seconds(2)) // Simulate some async work before calling onAction.

                onAction?(.didCompleteEnrollment)
            }
        }
    }
}
