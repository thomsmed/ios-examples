//
//  OnboardingView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct OnboardingView: View {

    @StateObject var viewModel: OnboardingViewModel

    @AppStorage("show") var show: Bool = false
    
    var body: some View {
        VStack {
            Text("Onboarding view")
            Button("Continue") {
                //viewModel.completeOnboarding()
                show = true
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(
            viewModel: .init(
                flowCoordinator: DummyFlowCoordinator.shared,
                appDependencies: DummyAppDependencies.shared
            )
        )
    }
}
