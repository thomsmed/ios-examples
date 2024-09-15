//
//  PageOneFeatureOneView.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import SwiftUI

struct PageOneFeatureOneView: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        VStack {
            Spacer()

            Button("Trigger Page Local Error") {
                viewModel.didTapTriggerPageLocalError()
            }

            Spacer()

            Button("Trigger Feature One Error") {
                viewModel.didTapTriggerFeatureError()
            }

            Spacer()

            Button("Trigger App Common Error") {
                viewModel.didTapTriggerCommonError()
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .alert(presenting: viewModel.alertDetails, isPresented: $viewModel.showAlert)
    }
}
