//
//  RootCoordinatorView.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import SwiftUI

struct RootCoordinatorView: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        Group {
            if viewModel.blocked {
                VStack {
                    Spacer()
                    Text("Ups! You are blocked until you re-launch the app")
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .transition(.blurReplace)
            } else {
                TabView {
                    Tab("Feature One", systemImage: "1.square") {
                        FeatureOneCoordinatorView(viewModel: viewModel.featureOneCoordinatorViewModel)
                    }

                    Tab("Feature Two", systemImage: "2.square") {
                        FeatureTwoCoordinatorView(viewModel: viewModel.featureTwoCoordinatorViewModel)
                    }
                }
            }
        }
        .animation(.default, value: viewModel.blocked)
        .alert(presenting: viewModel.alertDetails, isPresented: $viewModel.showAlert)
    }
}
