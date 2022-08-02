//
//  OnboardingFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct OnboardingFlowView: View {

    @StateObject var flowViewModel: OnboardingFlowViewModel

    var body: some View {
        ZStack {
            flowViewModel.makeOnboardingView()
        }
    }
}

struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlowView(
            flowViewModel: .init(
                flowCoordinator: DummyFlowCoordinator.shared,
                appDependencies: DummyAppDependencies.shared
            )
        )
    }
}
