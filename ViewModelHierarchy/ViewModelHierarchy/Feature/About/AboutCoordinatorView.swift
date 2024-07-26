//
//  AboutCoordinatorView.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 23/07/2024.
//

import SwiftUI

struct AboutCoordinatorView: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("General Info") {
                    Text("Some info")
                    Text("Some more info")
                }

                Section("Misc") {
                    LabeledContent("App Version") {
                        Text("1.0.0")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(role: .cancel) {
                        viewModel.didTapClose()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
            }
            .navigationTitle("About")
        }
    }
}

// MARK: AboutCoordinatorView+ViewModel

extension AboutCoordinatorView {
    @Observable
    final class ViewModel: ActionableViewModel<ViewModel.Action>, Hashable {
        enum Action {
            case didTapClose
        }

        // MARK: View Events

        func didTapClose() {
            onAction?(.didTapClose)
        }
    }
}
