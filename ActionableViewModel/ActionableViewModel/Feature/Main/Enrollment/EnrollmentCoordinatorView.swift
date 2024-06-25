//
//  EnrollmentCoordinatorView.swift
//  ActionableViewModel
//
//  Created by Thomas Asheim Smedmann on 15/06/2024.
//

import SwiftUI

struct EnrollmentCoordinatorView: View {
    @State var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Text("Hi there!")
                    .padding()

                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Button("Done") {
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
    final class ViewModel: ActionableViewModel<ViewModel.Action> {
        enum Action {
            case didCompleteEnrollment
        }

        var isLoading: Bool = false

        // MARK: View Events

        func didTapDone() {
            isLoading = true

            Task {
                try await Task.sleep(for: .seconds(3)) // Simulate some async work before calling onAction.

                onAction?(.didCompleteEnrollment)
            }
        }
    }
}
