//
//  WelcomeBackView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import SwiftUI

struct WelcomeBackView: View {

    @State var viewModel: WelcomeBackViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("Welcome back!")
                .padding(16)
            Button("Thanks!") {
                dismiss()
            }
            .padding(16)
            Button("Take me to booking") {
                viewModel.continueToBooking()
            }
            .padding(16)
        }
    }
}

struct WelcomeBackView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeBackView(
            viewModel: .init(
                flowCoordinator: PreviewFlowCoordinator.shared
            )
        )
    }
}
