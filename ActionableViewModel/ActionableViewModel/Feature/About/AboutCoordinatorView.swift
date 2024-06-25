//
//  AboutCoordinatorView.swift
//  ActionableViewModel
//
//  Created by Thomas Asheim Smedmann on 16/06/2024.
//

import SwiftUI

struct AboutCoordinatorView: View {
    @State var viewModel: ViewModel

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
    struct ViewModel: Actionable {
        enum Action {
            case didTapClose
        }

        var onAction: ((Action) -> Void)?

        // MARK: View Events

        func didTapClose() {
            onAction?(.didTapClose)
        }
    }
}
