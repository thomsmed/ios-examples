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
        TabView {
            flowViewModel.makeOnboardingView()
        }.tabViewStyle(.page)
    }
}

struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlowView(
            flowViewModel: .init(
                flowCoordinator: MockFlowCoordinator.shared,
                appDependencies: MockAppDependencies.shared
            )
        )
    }
}
