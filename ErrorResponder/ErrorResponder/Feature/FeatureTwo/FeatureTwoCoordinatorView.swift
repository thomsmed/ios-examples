//
//  FeatureTwoCoordinatorView.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import SwiftUI

struct FeatureTwoCoordinatorView: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.blocked {
                    VStack {
                        Spacer()
                        Text("Ups! You are blocked until you re-launch Feature Two")
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .transition(.blurReplace)
                } else {
                    PageOneFeatureTwoView(viewModel: viewModel.pageOneViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(.default, value: viewModel.blocked)
        }
        .alert(presenting: viewModel.alertDetails, isPresented: $viewModel.showAlert)
        .onDisappear(perform: viewModel.onDisappear)
    }
}
