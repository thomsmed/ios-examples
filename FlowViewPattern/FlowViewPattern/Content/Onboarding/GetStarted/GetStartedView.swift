//
//  GetStartedView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct GetStartedView: View {

    @State var viewModel: GetStartedViewModel
    
    var body: some View {
        VStack {
            Text("Awesome! 🙌")
                .padding()
            Button("Get started!") {
                viewModel.completeOnboarding()
            }
            .padding()
        }
    }
}

struct GetStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GetStartedView(
            viewModel: .init(
                flowCoordinator: PreviewFlowCoordinator.shared,
                appDependencies: PreviewAppDependencies.shared
            )
        )
    }
}
