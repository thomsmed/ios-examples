//
//  MoreView.swift
//  ActionableViewModel
//
//  Created by Thomas Asheim Smedmann on 15/06/2024.
//

import SwiftUI

struct MoreView: View {
    @State var viewModel: ViewModel

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
    struct ViewModel: Actionable {
        enum Action {
            case didTapDetails
            case didTapReEnroll
        }

        var onAction: ((Action) -> Void)?

        // MARK: View Events

        func didTapDetails() {
            onAction?(.didTapDetails)
        }

        func didTapReEnroll() {
            onAction?(.didTapReEnroll)
        }
    }
}
