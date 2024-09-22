//
//  FeatureOneCoordinatorView.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import SwiftUI

struct FeatureOneCoordinatorView: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.blocked {
                    VStack {
                        Spacer()
                        Text("Ups! You are blocked until you re-launch Feature One")
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .transition(.blurReplace)
                } else {
                    PageOneFeatureOneView(viewModel: viewModel.pageOneViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(.default, value: viewModel.blocked)
        }
        .alert(presenting: viewModel.alertDetails, isPresented: $viewModel.showAlert)
        .onDisappear(perform: viewModel.onDisappear)
    }
}