//
//  OnboardingFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct OnboardingFlowView: View {

    @StateObject var flowViewModel: OnboardingFlowViewModel
    let flowViewFactory: OnboardingFlowViewFactory

    var body: some View {
        TabView {
            flowViewFactory.makeOnboardingView(with: flowViewModel)
        }.tabViewStyle(.page)
    }
}

struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlowView(
            flowViewModel: .init(
                flowCoordinator: PreviewFlowCoordinator.shared
            ),
            flowViewFactory: PreviewFlowViewFactory.shared
        )
    }
}
