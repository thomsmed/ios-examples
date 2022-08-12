//
//  OnboardingView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct OnboardingView: View {

    @State var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack {
            Text("Onboarding view")
            Button("Continue") {
                viewModel.completeOnboarding()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(
            viewModel: .init(
                flowCoordinator: PreviewFlowCoordinator.shared,
                appDependencies: PreviewAppDependencies.shared
            )
        )
    }
}
