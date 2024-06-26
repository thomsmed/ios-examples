//
//  HomeView.swift
//  ActionableViewModel
//
//  Created by Thomas Asheim Smedmann on 15/06/2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        ScrollView {
            Text("Welcome Home")
                .padding()

            Button("View Profile") {
                viewModel.didTapProfile()
            }
            .padding()
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

// MARK: HomeView+ViewModel

extension HomeView {
    final class ViewModel: ActionableViewModel<ViewModel.Action> {
        enum Action {
            case didTapProfile
            case didTapSettings
            case didTapAbout
        }

        // MARK: View Events

        func didTapProfile() {
            onAction?(.didTapProfile)
        }

        func didTapSettings() {
            onAction?(.didTapSettings)
        }

        func didTapAbout() {
            onAction?(.didTapAbout)
        }
    }
}
